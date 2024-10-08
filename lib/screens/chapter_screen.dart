import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/provider/paragraph_builder.dart';
import 'package:simple_bible/provider/parsed_line.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/widgets/zoom_widget.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool isReady = false;
  dynamic book = {};
  String bibles = "";
  late int chapter = 1;
  late int totalChapter = 0;
  late Map<String, dynamic> args;
  late BaseModel baseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
  }

  initData() async {
    if (book != null || book != '') {
      isReady = true;
      chapter = args['chapter'] + 1;
      book = args['book'];
      totalChapter = book['chapters'].asMap().length;
      setState(() {});
    }
  }

  renderVerses() {
    List<ParsedLine> lines = [];

    for (final verse
        in book['chapters'][chapter - 1]['verses'].asMap().entries) {
      lines.add(ParsedLine(
          verse: '${verse.key + 1}',
          verseText: verse.value['text'].replaceAll("\n", " "),
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

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    args = (ModalRoute.of(context)!.settings.arguments ?? <String, dynamic>{})
        as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(isReady ? '${book['book']}' : "Loading")),
      body: ZoomWidget(
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: !isReady
                  ? [const CircularProgressIndicator()]
                  : [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (chapter > 1) {
                                chapter--;
                                setState(() {});
                              }
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: chapter > 1 ? Colors.red : Colors.grey,
                              size: 24 * baseModel.fontScale,
                            ),
                          ),
                          Text(
                            "Chapter $chapter",
                            style: TextStyle(
                              fontSize: 30 * baseModel.fontScale,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (chapter < totalChapter) {
                                chapter++;
                                setState(() {});
                              }
                            },
                            child: Icon(
                              Icons.arrow_forward,
                              color: chapter < totalChapter
                                  ? Colors.red
                                  : Colors.grey,
                              size: 24 * baseModel.fontScale,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      renderVerses(),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
