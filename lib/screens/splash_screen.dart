import 'package:flutter/material.dart';
import 'package:simple_bible/api/bible.api.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/widgets/main_screen_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late BaseModel baseModel;
  late DB db;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      preloadCheck();
    });
  }

  preloadCheck() async {
    await baseModel.initData();

    db = DB();
    await db.init();

    BibleAPI bibleAPI = BibleAPI();

    var languageCountQuery = await db.db.query('languages');

    if (languageCountQuery.isEmpty) {
      // Handle error if languages fail to load
      await bibleAPI.loadLanguages();
    }

    final bookCount = await db.db.query('books');

    if (baseModel.defaultLanguage.isEmpty ||
        baseModel.defaultVersion.isEmpty ||
        bookCount.isEmpty) {
      Navigator.pushReplacementNamed(context, "/setup");
      return;
    }

    await baseModel.loadDataFromDB();
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return Scaffold(
      body: MainScreenWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/main-logo.png',
              width: 180,
            )
          ],
        ),
      ),
    );
  }
}
