import 'package:flutter/material.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:simple_bible/dto/version_dto.dart';
import 'package:simple_bible/utils/colours.dart';

class VersionSelectionWidget extends StatefulWidget {
  final Function(VersionDTO?) callback;
  final LanguageDTO selectedLanguage;
  final Function()? prevCallback;
  final VersionDTO? initialVersion;

  const VersionSelectionWidget({
    super.key,
    required this.callback,
    this.initialVersion,
    this.prevCallback,
    required this.selectedLanguage,
  });

  @override
  State<VersionSelectionWidget> createState() => _VersionSelectionWidgetState();
}

class _VersionSelectionWidgetState extends State<VersionSelectionWidget> {
  final db = DB.database;
  VersionDTO? selectedVersion;
  List<VersionDTO> versions = [];

  @override
  void initState() {
    super.initState();
    selectedVersion = widget.initialVersion;
    loadVersions();
  }

  loadVersions() async {
    final records = await db.query('versions',
        where: "languageId = ?", whereArgs: [widget.selectedLanguage.id]);

    versions.clear();

    for (final record in records) {
      versions.add(VersionDTO.fromDatabase(record));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            initialValue: selectedVersion,
            items: versions
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.grey,
                ),
              ),
              onPressed: () {
                widget.prevCallback?.call();
              },
              child: const Text(
                'Prev',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  selectedVersion != null ? themeColor : Colors.grey,
                ),
              ),
              onPressed: () {
                widget.callback(selectedVersion!);
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )
      ],
    );
  }
}
