import 'dart:convert';

import 'package:simple_bible/dto/version_dto.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static late Database database;

  init() async {
    await initDatabase();
  }

  get db {
    return DB.database;
  }

  close() async {
    await DB.database?.close();
  }

  Future<void> initDatabase() async {
    // await deleteDatabase(
    //     'bible.db'); // For testing purposes, delete existing database

    final dbPath = await getDatabasesPath();
    print("Database path is ${dbPath}");

    DB.database = await openDatabase(
      'bible.db',
      version: 2,
      onCreate: (Database db, int version) async {
        print("Creating database...");

        await db.execute('''
          CREATE TABLE IF NOT EXISTS languages (
            id INTEGER PRIMARY KEY,
            name TEXT,
            code TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS versions (
            id INTEGER PRIMARY KEY,
            languageId INTEGER,
            name TEXT,
            version TEXT,
            translation TEXT,
            oldTestament TEXT,
            newTestament TEXT,
            FOREIGN KEY(languageId) REFERENCES languages(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY,
            `order` INTEGER,
            name TEXT,
            versionId INTEGER,
            FOREIGN KEY(versionId) REFERENCES versions(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS chapters (
            id INTEGER PRIMARY KEY,
            `order` INTEGER,
            name TEXT nullable,
            bookId INTEGER,
            FOREIGN KEY(bookId) REFERENCES books(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS verses (
            id INTEGER PRIMARY KEY,
            `order` INTEGER,
            content TEXT,
            chapterId INTEGER,
            FOREIGN KEY(chapterId) REFERENCES chapters(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Handle database upgrade if needed
        print("Upgrading database from version $oldVersion to $newVersion");

        // Fix testament typo in translations for older versions
        if (oldVersion < 2) {
          final versions = await db.query('versions');
          for (final version in versions) {
            final dto = VersionDTO.fromDatabase(version);

            if (dto.translation!['oldTestament']!
                    .toLowerCase()
                    .contains('testiment') ||
                dto.translation!['newTestament']!
                    .toLowerCase()
                    .contains('testiment')) {
              dto.translation!['oldTestament'] = dto
                  .translation!['oldTestament']!
                  .replaceAll('Testiment', 'Testament');
              dto.translation!['newTestament'] = dto
                  .translation!['newTestament']!
                  .replaceAll('Testiment', 'Testament');
              await db.update(
                'versions',
                {'translation': jsonEncode(dto.translation)},
                where: 'id = ?',
                whereArgs: [dto.id],
              );
            }
          }
        }
      },
      onOpen: (Database db) async {},
    );
  }
}
