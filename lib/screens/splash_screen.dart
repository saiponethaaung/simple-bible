import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/widgets/main_screen_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late BaseModel baseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadCheck();
    });
  }

  preloadCheck() async {
    await baseModel.initData();

    if (baseModel.defaultLanguage.isEmpty || baseModel.books.isEmpty) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? languageJSON = sh.getString('languages');

      if (languageJSON == null) {
        Uri url = Uri.parse(
            'https://raw.githubusercontent.com/saiponethaaung/Bible-JSON/main/bible/languages.json');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          languageJSON = response.body;
          sh.setString('languages', languageJSON);
        } else {
          // Todo handle api response error
        }
      }

      baseModel.setupLanguage(languageJSON!);

      Navigator.pushReplacementNamed(context, "/setup");
    } else {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  setupLanguage() {}

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return const Scaffold(
      body: MainScreenWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('The'),
            Text(
              'Holy Bible',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
