import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        padding: EdgeInsets.all(10),
        child: GestureDetector(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
              ),
              color: Colors.blue,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '${b + 1}',
                style: TextStyle(
                  color: Colors.white,
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
    BaseModel baseModel = Provider.of<BaseModel>(context);
    args = (ModalRoute.of(context)!.settings.arguments ?? '') as String;

    return Scaffold(
      appBar: AppBar(title: Text(isReady ? book['book'] : "Loading")),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: !isReady
                ? [CircularProgressIndicator()]
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
