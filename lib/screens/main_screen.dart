import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        child: Text(book.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Holy Bible'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.clear),
      //   onPressed: () {
      //     clearAllState();
      //   },
      // ),
      body: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: TabBar(
            tabs: tabs,
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ...baseModel.books.entries.take(39).map((book) {
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
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ...baseModel.books.entries.skip(39).map((book) {
                        return renderBook(book);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
