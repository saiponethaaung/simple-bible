import 'dart:convert';

class BookDTO {
  int id;
  int order;
  int versionId;
  String name;

  BookDTO(this.id, this.name, this.order, this.versionId);

  factory BookDTO.fromDatabase(dynamic data) {
    return BookDTO(
      data['id'] as int,
      data['name'] as String,
      data['order'] as int,
      data['versionId'] as int,
    );
  }
}
