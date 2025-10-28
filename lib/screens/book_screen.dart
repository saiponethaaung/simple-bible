import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/chapter_dto.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/widgets/zoom_widget.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool isReady = false;
  late BookDTO book;
  String bibles = "";
  List<ChapterDTO> chapters = [];
  late BaseModel baseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
  }

  initData() async {
    final db = DB.database;

    if (book != null) {
      isReady = true;
      final chapters = await db.query('chapters',
          where: 'bookId = ?', whereArgs: [book.id], orderBy: '`order` ASC');

      for (final chapter in chapters) {
        this.chapters.add(ChapterDTO.fromDatabase(chapter));
      }

      setState(() {});
    }
  }

  renderChapter() {
    List<Widget> list = [];

    for (final chapter in chapters) {
      list.add(Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          child: Container(
            width: 40 * baseModel.fontScale,
            height: 40 * baseModel.fontScale,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(97, 45, 27, 0.698),
              ),
              color: const Color.fromRGBO(97, 45, 27, 0.698),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                chapter.order.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * baseModel.fontScale,
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/chapter', arguments: {
              "chapter": chapter,
              "book": book,
            });
          },
        ),
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    book = (ModalRoute.of(context)!.settings.arguments) as BookDTO;

    return Scaffold(
      appBar: AppBar(title: Text(isReady ? book.name : "Loading")),
      body: ZoomWidget(
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: !isReady
                ? [const CircularProgressIndicator()]
                : [
                    Wrap(
                      children: renderChapter(),
                    )
                  ],
          ),
        ),
      ),
    );
  }
}
