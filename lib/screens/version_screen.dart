import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/api/bible.api.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/dto/version_dto.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:sqflite/sqflite.dart';

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  late BaseModel baseModel;
  Database db = DB.database;
  List<VersionDTO> versions = [];

  String downloadDialog = 'Downloading {{book}} of {{bookTotal}}...';
  int downloadCount = 0;
  int bookTotal = 0;
  bool showProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  loadData() async {
    versions = (await db.query('versions'))
        .map((e) => VersionDTO.fromDatabase(e))
        .toList();
    setState(() {});
  }

  changeVersion(VersionDTO version) async {
    final books = await db.query(
      'books',
      where: 'versionId = ?',
      whereArgs: [version.id],
    );

    final language = LanguageDTO.fromDatabase((await db.query(
      'languages',
      where: 'id = ?',
      whereArgs: [version.languageId],
    ))[0]);

    if (books.isEmpty) {
      print("Downloading books for the selected version...");
      BibleAPI bibleAPI = BibleAPI();

      showProgress = true;
      setState(() {});

      await bibleAPI.loadBooks(language, version);

      var books = (await db.query(
        'books',
        where: 'versionId = ?',
        whereArgs: [version.id],
        orderBy: '`order` asc',
      ))
          .map((b) => BookDTO.fromDatabase(b))
          .toList();

      // download Books
      bookTotal = books.length;
      setState(() {});

      for (final book in books) {
        downloadCount++;
        setState(() {});
        await bibleAPI.downloadBook(language, version, book);
      }
    }

    SharedPreferences sh = await SharedPreferences.getInstance();

    sh.setString('defaultLanguage', language.id.toString());
    sh.setString('defaultVersion', version.id.toString());
    sh.setDouble('fontScale', 1.0);
    sh.setInt('newTestamentStart', version.newTestamentStart);

    baseModel.defaultLangauge = language.id.toString();
    baseModel.defaultVersion = version.id.toString();
    await baseModel.initData();
    await baseModel.loadDataFromDB();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Version'),
      ),
      body: Stack(
        children: [
          Center(
            child: ListView.builder(
              itemCount: versions.length,
              itemBuilder: (context, index) {
                VersionDTO version = versions[index];
                return ListTile(
                  title: Text(version.name +
                      (baseModel.version?.id != version.id
                          ? ''
                          : ' (Current)')),
                  enabled: baseModel.version?.id != version.id,
                  onTap: () {
                    changeVersion(version);
                  },
                );
              },
            ),
          ),
          Visibility(
            visible: showProgress,
            child: Positioned(
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      downloadDialog
                          .replaceFirst(
                            "{{book}}",
                            downloadCount.toString(),
                          )
                          .replaceFirst("{{bookTotal}}", bookTotal.toString()),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
