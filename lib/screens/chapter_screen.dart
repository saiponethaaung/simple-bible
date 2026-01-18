import 'package:flutter/material.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/chapter_dto.dart';
import 'package:simple_bible/dto/verse_dto.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/provider/paragraph_builder.dart';
import 'package:simple_bible/provider/parsed_line.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/widgets/zoom_widget.dart';
import 'package:sqflite/sqflite.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool isReady = false;
  Database db = DB.database;
  late BookDTO book;
  late ChapterDTO chapter;
  late int totalChapter = 0;
  late BaseModel baseModel;
  late dynamic args;
  List<VerseDTO> verses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
  }

  initData() async {
    isReady = true;
    book = args['book'];
    chapter = args['chapter'];

    totalChapter = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chapters WHERE bookId = ?',
        [book.id]).then((value) => value.first['count'] as int);

    await changeChapter(chapter.order);
  }

  changeChapter(int chapterOrder) async {
    chapter = ChapterDTO.fromDatabase((await db.query('chapters',
            where: 'bookId = ? AND `order` = ?',
            whereArgs: [book.id, chapterOrder]))
        .first);

    final verseRecords = await db.query('verses',
        where: 'chapterId = ?',
        whereArgs: [chapter.id],
        orderBy: '`order` ASC');

    verses = verseRecords.map((data) => VerseDTO.fromDatabase(data)).toList();

    setState(() {});
  }

  renderVerses() {
    List<ParsedLine> lines = [];

    for (final verse in verses) {
      print("-" * 20);
      print(verse.order);
      print(verse.content.replaceAll("\n", " ").replaceAll("\\+add", "").replaceAll("\\+add*", ""));
      lines.add(ParsedLine(
          verse: '${verse.order}',
          verseText: verse.content.replaceAll("\n", " ").replaceAll("\\+add", "").replaceAll("\\+add*", ""),
          verseStyle: 'v'));
    }

    return ParagraphBuilder(
      paragraph: lines,
      textDirection: TextDirection.ltr,
      fontSize: 18 * baseModel.fontScale,
      rangeOfVersesToCopy: const [],
      addVerseToCopyRange: (lines) {},
    );
  }

  chapterIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            if (chapter.order > 1) {
              await changeChapter(chapter.order - 1);
              setState(() {});
            }
          },
          child: Icon(
            Icons.arrow_back,
            color: chapter.order > 1 ? Colors.red : Colors.grey,
            size: 24 * baseModel.fontScale,
          ),
        ),
        Text(
          "Chapter ${chapter.order}",
          style: TextStyle(
            fontSize: 30 * baseModel.fontScale,
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (chapter.order < totalChapter) {
              await changeChapter(chapter.order + 1);
              setState(() {});
            }
          },
          child: Icon(
            Icons.arrow_forward,
            color: chapter.order < totalChapter ? Colors.red : Colors.grey,
            size: 24 * baseModel.fontScale,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(isReady ? '${book.name}' : "Loading")),
      body: ZoomWidget(
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: !isReady
                  ? [const CircularProgressIndicator()]
                  : [
                      chapterIndicator(),
                      const SizedBox(height: 30),
                      renderVerses(),
                      const SizedBox(height: 15),
                      chapterIndicator(),
                      const SizedBox(height: 30),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
