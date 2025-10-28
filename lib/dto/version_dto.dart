import 'dart:convert';

class VersionDTO {
  int id;
  String version;
  String name;
  int newTestamentStart;
  int languageId;
  Map<String, String>? translation = {};

  VersionDTO(
    this.id,
    this.version,
    this.name,
    this.newTestamentStart,
    this.languageId,
    this.translation,
  );

  factory VersionDTO.fromDatabase(dynamic data) {
    Map<String, dynamic> newTestament =
        jsonDecode(data['newTestament'] as String);
    return VersionDTO(
      data['id'] as int,
      data['version'] as String,
      data['name'] as String,
      newTestament['start'],
      data['languageId'] as int,
      Map<String, String>.from(jsonDecode(data['translation'] as String)),
    );
  }
}
