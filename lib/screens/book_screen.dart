import 'dart:convert';

import 'package:flutter/material.dart';
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
  dynamic book = {};
  String bibles = "";
  late String args;
  late BaseModel baseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
  }

  initData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    book = jsonDecode(sh.getString('book$args') ?? '');

    if (book != null || book != '') {
      isReady = true;
      setState(() {});
    }
  }

  renderChapter() {
    List<Widget> list = [];

    for (final b in book['chapters'].asMap().keys) {
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
                '${b + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * baseModel.fontScale,
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/chapter', arguments: {
              "chapter": b,
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
    args = (ModalRoute.of(context)!.settings.arguments ?? '') as String;

    return Scaffold(
      appBar: AppBar(title: Text(isReady ? book['book'] : "Loading")),
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
