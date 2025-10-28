import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/dto/version_dto.dart';
import 'package:sqflite/sqlite_api.dart';

class BibleAPI {
  String baseUrl =
      'https://raw.githubusercontent.com/saiponethaaung/Bible-JSON/main/bible';

  loadLanguages() async {
    try {
      Database db = DB.database;
      Uri url = Uri.parse('$baseUrl/languages.json');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final languageJSON = response.body;
        Map<String, dynamic> body = jsonDecode(languageJSON);

        for (var entry in body.entries) {
          // Check language and create if missing
          var record = await db.query(
            'languages',
            where: 'code = ?',
            whereArgs: [entry.value['code']],
          );

          if (!record.isNotEmpty) {
            await db.insert('languages', {
              'name': entry.value['name'],
              'code': entry.value['code'],
            });
          }

          record = await db.query(
            'languages',
            where: 'code = ?',
            whereArgs: [entry.value['code']],
          );

          for (var version in entry.value['versions']) {
            var existingVersion = await db.query(
              'versions',
              where: 'languageId = ? AND version = ?',
              whereArgs: [record[0]['id'], version['version']],
            );

            if (existingVersion.isNotEmpty) {
              continue;
            }

            await db.insert('versions', {
              'languageId': record[0]['id'],
              'name': version['name'],
              'version': version['version'],
              'translation': jsonEncode(version['translations']),
              'oldTestament': jsonEncode(version['oldTestament']),
              'newTestament': jsonEncode(version['newTestament'])
            });
          }
        }
        return {"status": true, "message": "Languages loaded"};
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  loadBooks(LanguageDTO language, VersionDTO version) async {
    try {
      Database db = DB.database;

      Uri url = Uri.parse(
          '$baseUrl/languages/${language.code}/${version.version}/books.json');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        final booksJSON = response.body;
        Map<dynamic, dynamic> bookDynamic = jsonDecode(booksJSON);

        await db.delete(
          'books',
          where: 'versionId = ?',
          whereArgs: [version.id],
        );

        bookDynamic.forEach((key, book) async {
          final input = {
            'order': key,
            'name': book,
            'versionId': version.id,
          };
          await db.insert('books', input);
        });
      } else {
        // Todo handle api response error
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  downloadBook(LanguageDTO language, VersionDTO version, BookDTO book) async {
    try {
      Database db = DB.database;
      Uri url = Uri.parse(
          '$baseUrl/languages/${language.code}/${version.version}/json/${book.order}.json');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final chapters = body['chapters'];

        await db.delete(
          'chapters',
          where: 'bookId = ?',
          whereArgs: [book.id],
        );

        for (final chapter in chapters) {
          final chapterId = await db.insert('chapters', {
            'order': chapter['number'],
            'bookId': book.id,
          });

          final verses = chapter['verses'];

          await db.delete(
            'verses',
            where: 'chapterId = ?',
            whereArgs: [chapterId],
          );

          for (final verse in verses) {
            await db.insert('verses', {
              'order': verse['number'],
              'content': verse['text'],
              'chapterId': chapterId,
            });
          }
        }

        return {"status": true, "message": "Book downloaded"};
      } else {
        return {"status": false, "message": "Failed to load book"};
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }
}
