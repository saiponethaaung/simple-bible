import 'package:simple_bible/dto/version_dto.dart';

class LanguageDTO {
  String name;
  List<VersionDTO> versions;

  LanguageDTO(this.name, this.versions);

  factory LanguageDTO.fromJSON(String name, List<dynamic> versions) {
    List<VersionDTO> versionList = [];

    for (final v in versions) {
      versionList.add(VersionDTO(v['version'], v['name']));
    }

    return LanguageDTO(name, versionList);
  }
}
