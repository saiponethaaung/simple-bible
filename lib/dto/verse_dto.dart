class VerseDTO {
  int id;
  int order;
  String content;

  VerseDTO(this.id, this.order, this.content);

  factory VerseDTO.fromDatabase(dynamic data) {
    return VerseDTO(
      data['id'] as int,
      data['order'] as int,
      data['content'] as String,
    );
  }
}
