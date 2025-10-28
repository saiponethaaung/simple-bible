import 'package:flutter/material.dart';
import 'package:simple_bible/api/bible.api.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/dto/version_dto.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/widgets/language_selection_widget.dart';
import 'package:simple_bible/widgets/main_screen_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/widgets/version_selection_widget.dart';
import 'package:sqflite/sqflite.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late SharedPreferences sh;
  late BaseModel baseModel;
  Database db = DB.database;
  BibleAPI bibleAPI = BibleAPI();

  String section = 'language';
  String downloadDialog = 'Downloading {{book}} of {{bookTotal}}...';
  int downloadCount = 0;
  int bookTotal = 0;
  bool showProgress = false;

  LanguageDTO? selectedLanguage;
  VersionDTO? selectedVersion;

  List<VersionDTO> versions = [];
  List<BookDTO> books = [];

  @override
  void initState() {
    super.initState();
  }

  donwloadFiles(context) async {
    sh = await SharedPreferences.getInstance();
    await downloadBooks(context);
  }

  downloadBooks(context) async {
    showProgress = true;

    setState(() {});

    await bibleAPI.loadBooks(selectedLanguage!, selectedVersion!);

    books = (await db.query(
      'books',
      where: 'versionId = ?',
      whereArgs: [selectedVersion!.id],
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
      await bibleAPI.downloadBook(selectedLanguage!, selectedVersion!, book);
    }

    sh.setString('defaultLanguage', selectedLanguage!.id.toString());
    sh.setString('defaultVersion', selectedVersion!.id.toString());
    sh.setDouble('fontScale', 1.0);
    sh.setInt('newTestamentStart', selectedVersion!.newTestamentStart);

    Navigator.pushReplacementNamed(context, '/splash-screen');
  }

  Widget renderUI() {
    switch (section) {
      case 'language':
        return LanguageSelectionWidget(
          callback: (language) {
            if (language != null) {
              selectedLanguage = language;
              selectedVersion = null;
              section = 'version';
              setState(() {});
            }
          },
          initialLanguage: selectedLanguage,
        );
      case 'version':
        return VersionSelectionWidget(
          callback: (version) {
            if (version != null) {
              selectedVersion = version;
              donwloadFiles(context);
              setState(() {});
            }
          },
          prevCallback: () => {
            section = 'language',
            setState(() {}),
          },
          selectedLanguage: selectedLanguage!,
        );
      default:
        return const SizedBox(
          width: 0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          MainScreenWidget(
            child: renderUI(),
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
