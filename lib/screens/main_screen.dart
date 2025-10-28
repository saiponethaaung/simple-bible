import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/widgets/zoom_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void openWebsite() async {
    Uri url = Uri.parse("https://placeinheart.com");

    await launchUrl(url);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadCheck();
    });
  }

  preloadCheck() async {
    print("Preload check started...");
  }

  clearAllState() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseModel.books = [];
    baseModel.languages = {};
    baseModel.defaultLangauge = '';
    sh.clear();
    Navigator.pushReplacementNamed(context, '/splash-screen');
  }

  renderBook(book) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/book', arguments: book);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Text(
          book.name,
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

    if (baseModel.version == null || baseModel.books.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    tabs = [
      Tab(
          text: baseModel.version!.translation!['oldTestament'] ??
              'Old Testament'),
      Tab(
          text: baseModel.version!.translation!['newTestament'] ??
              'New Testament'),
    ];

    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 50, bottom: 30),
                  child: Image.asset(
                    'assets/logo/main-logo.png',
                    width: 150,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/version');
                          },
                          child: const Text('Change version'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                          child: const Text('About'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => openWebsite(),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(30),
                child: const Text(
                  '❤️ by Place in Heart ❤️',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'The Holy Bible',
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(Icons.translate),
              onPressed: () {
                Navigator.pushNamed(context, '/version');
              },
            ),
          ),
        ],
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
                      children: baseModel.version != null &&
                              baseModel.version!.newTestamentStart == 0
                          ? []
                          : <Widget>[
                              ...baseModel.books
                                  .take(
                                      baseModel.version!.newTestamentStart - 1)
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
                      children: baseModel.version!.newTestamentStart == 0
                          ? []
                          : <Widget>[
                              ...baseModel.books
                                  .skip(
                                      baseModel.version!.newTestamentStart - 1)
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
