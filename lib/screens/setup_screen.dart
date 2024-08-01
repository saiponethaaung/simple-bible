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
  String downloadDialog = 'Downloading {{book}} of 66...';
  bool showProgress = false;
  LanguageDTO? selectedLanguage;
  VersionDTO? selectedVersion;
  late SharedPreferences sh;

  late BaseModel baseModel;

  @override
  void initState() {
    super.initState();
  }

  donwloadFiles() async {
    sh = await SharedPreferences.getInstance();
    await downloadBooks();
  }

  downloadBooks() async {
    showProgress = true;

    setState(() {});

    String? booksJSON = sh.getString('books');
    String baseURL =
        'https://raw.githubusercontent.com/saiponethaaung/Bible-JSON/main/bible/languages/${selectedLanguage?.name.toLowerCase()}/${selectedVersion?.name}';

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
            DropdownMenu(
              hintText: "Select a language",
              dropdownMenuEntries: baseModel.languages.entries
                  .map((l) => DropdownMenuEntry(
                        value: l.value,
                        label: l.value.name,
                      ))
                  .toList(),
              onSelected: (language) {
                selectedLanguage = language;
                setState(() {});
              },
            ),
            selectedLanguage != null
                ? TextButton(
                    onPressed: () {
                      section = 'version';
                      setState(() {});
                    },
                    child: const Text('Next'))
                : const SizedBox(
                    width: 0,
                  ),
          ],
        );
      case 'version':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Select a version'),
            DropdownMenu(
              hintText: "Select a version",
              dropdownMenuEntries: selectedLanguage!.versions
                  .map((v) => DropdownMenuEntry(
                        value: v,
                        label: v.name,
                      ))
                  .toList(),
              onSelected: (version) {
                selectedVersion = version;
                setState(() {});
              },
            ),
            selectedVersion != null
                ? TextButton(
                    onPressed: () {
                      donwloadFiles();
                    },
                    child: const Text('Next'))
                : const SizedBox(
                    width: 0,
                  ),
            Text('Show progress ${showProgress}')
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
                      downloadDialog.replaceFirst(
                        "{{book}}",
                        downloadCount.toString(),
                      ),
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
