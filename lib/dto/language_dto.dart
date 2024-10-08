import 'package:simple_bible/dto/version_dto.dart';

class LanguageDTO {
  String name;
  String code;
  List<VersionDTO> versions;

  LanguageDTO(this.name, this.code, this.versions);

  factory LanguageDTO.fromJSON(
      String name, String code, List<dynamic> versions) {
    List<VersionDTO> versionList = [];

    for (final v in versions) {
      versionList.add(VersionDTO(
        v['version'],
        v['name'],
        v['newTestament']['start'],
      ));
    }

    return LanguageDTO(name, code, versionList);
  }
}
