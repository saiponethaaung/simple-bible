import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/dto/version_dto.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/widgets/main_screen_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String section = 'language';
  int downloadCount = 0;
  int bookTotal = 0;
  String downloadDialog = 'Downloading {{book}} of {{bookTotal}}...';
  bool showProgress = false;
  LanguageDTO? selectedLanguage;
  VersionDTO? selectedVersion;
  late SharedPreferences sh;

  late BaseModel baseModel;

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

    String? booksJSON = sh.getString('books');
    String baseURL =
        'https://raw.githubusercontent.com/saiponethaaung/Bible-JSON/main/bible/languages/${selectedLanguage?.code.toLowerCase()}/${selectedVersion?.version}';

    if (booksJSON == null) {
      Uri url = Uri.parse('$baseURL/books.json');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        booksJSON = response.body;
        sh.setString('books', response.body);
      } else {
        // Todo handle api response error
      }
    }

    baseModel.setBooks(booksJSON ?? '');

    // download Books

    bookTotal = baseModel.books.keys.length;
    setState(() {});

    for (final key in baseModel.books.keys) {
      downloadCount++;
      setState(() {});
      Uri bookURL = Uri.parse('$baseURL/json/$key.json');
      var response = await http.get(bookURL);

      if (response.statusCode == 200) {
        sh.setString('book$key', response.body);
      } else {
        // Todo handle api response error
      }
    }
    sh.setString('defaultLanguage', selectedLanguage!.name);
    sh.setDouble('fontScale', 1.0);
    sh.setInt('newTestamentStart', selectedVersion!.newTestamentStart);
    baseModel.newTestamentStart = selectedVersion!.newTestamentStart;
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget renderUI() {
    switch (section) {
      case 'language':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Select a language'),
            Container(
              width: 300,
              padding: const EdgeInsets.all(15),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(),
                hint: const Text("Select a language"),
                value: selectedLanguage,
                items: baseModel.languages.entries
                    .map((l) => DropdownMenuItem(
                          value: l.value,
                          child: Text(l.value.name),
                        ))
                    .toList(),
                onChanged: (language) {
                  selectedLanguage = language;
                  setState(() {});
                },
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  selectedLanguage != null
                      ? const Color.fromRGBO(103, 33, 9, 1)
                      : Colors.grey,
                ),
              ),
              onPressed: () {
                if (selectedLanguage != null) {
                  section = 'version';
                  setState(() {});
                }
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      case 'version':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Select a version'),
            Container(
              width: 300,
              padding: const EdgeInsets.all(15),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(),
                hint: const Text("Select a version"),
                value: selectedVersion,
                items: selectedLanguage?.versions
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.name),
                        ))
                    .toList(),
                onChanged: (version) {
                  selectedVersion = version;
                  setState(() {});
                },
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  selectedVersion != null
                      ? const Color.fromRGBO(103, 33, 9, 1)
                      : Colors.grey,
                ),
              ),
              onPressed: () {
                if (selectedVersion != null) {
                  donwloadFiles(context);
                }
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
