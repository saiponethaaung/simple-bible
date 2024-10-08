import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/widgets/zoom_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BaseModel baseModel;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Old Testament'),
    const Tab(text: 'New Testament'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadCheck();
    });
  }

  preloadCheck() async {}

  clearAllState() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseModel.books = {};
    baseModel.languages = {};
    baseModel.defaultLangauge = '';
    sh.clear();
    Navigator.pushReplacementNamed(context, '/splash-screen');
  }

  renderBook(book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/book', arguments: book.key);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Text(
          book.value,
          style: TextStyle(
            fontSize: 14 * baseModel.fontScale,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'The Holy Bible',
        ),
        leading: const SizedBox(),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.clear),
      //   onPressed: () {
      //     clearAllState();
      //   },
      // ),
      body: ZoomWidget(
        DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: TabBar(
              tabs: tabs,
              labelStyle: TextStyle(
                fontSize: 14 * baseModel.fontScale,
              ),
            ),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: baseModel.newTestamentStart == 0
                          ? []
                          : <Widget>[
                              ...baseModel.books.entries
                                  .take(baseModel.newTestamentStart - 1)
                                  .map((book) {
                                return renderBook(book);
                              }),
                            ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: baseModel.newTestamentStart == 0
                          ? []
                          : <Widget>[
                              ...baseModel.books.entries
                                  .skip(baseModel.newTestamentStart - 1)
                                  .map(
                                (book) {
                                  return renderBook(
                                    book,
                                  );
                                },
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
