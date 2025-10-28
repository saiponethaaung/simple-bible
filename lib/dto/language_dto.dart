import 'package:simple_bible/dto/version_dto.dart';

class LanguageDTO {
  int id;
  String name;
  String code;
  List<VersionDTO> versions;

  LanguageDTO(this.id, this.name, this.code, this.versions);

  factory LanguageDTO.fromDatabase(dynamic dbRecord) {
    return LanguageDTO(
      dbRecord['id'],
      dbRecord['name'],
      dbRecord['code'],
      [],
    );
  }

  // factory LanguageDTO.fromJSON(
  //     String name, String code, List<dynamic> versions) {
  // List<VersionDTO> versionList = [];

  // for (final v in versions) {
  //   versionList.add(VersionDTO(
  //     v['version'],
  //     v['name'],
  //     v['newTestament']['start'],
  //   ));
  // }

  // return LanguageDTO(name, code, versionList);
  // }
}
