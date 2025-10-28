import 'dart:convert';

class ChapterDTO {
  int id;
  int order;

  ChapterDTO(this.id, this.order);

  factory ChapterDTO.fromDatabase(dynamic data) {
    return ChapterDTO(
      data['id'] as int,
      data['order'] as int,
    );
  }
}
