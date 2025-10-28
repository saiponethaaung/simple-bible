import 'package:flutter/material.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/utils/colours.dart';

class LanguageSelectionWidget extends StatefulWidget {
  final Function(LanguageDTO?) callback;
  final LanguageDTO? initialLanguage;

  const LanguageSelectionWidget(
      {super.key, required this.callback, this.initialLanguage});

  @override
  State<LanguageSelectionWidget> createState() =>
      _LanguageSelectionWidgetState();
}

class _LanguageSelectionWidgetState extends State<LanguageSelectionWidget> {
  final db = DB.database;
  LanguageDTO? selectedLanguage;
  List<LanguageDTO> languages = [];

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
    loadLanguages();
  }

  loadLanguages() async {
    languages = (await db.query('languages'))
        .map((l) => LanguageDTO.fromDatabase(l))
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            // initialValue: languages.isNotEmpty ? selectedLanguage : null,
            items: languages
                .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l.name),
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
              selectedLanguage != null ? themeColor : Colors.grey,
            ),
          ),
          onPressed: () {
            widget.callback(selectedLanguage!);
          },
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
