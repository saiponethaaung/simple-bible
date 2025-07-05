import 'package:flutter/material.dart';
import 'package:simple_bible/models/base_model.dart';
import 'package:simple_bible/screens/chapter_screen.dart';
import 'package:simple_bible/screens/main_screen.dart';
import 'package:simple_bible/screens/book_screen.dart';
import 'package:simple_bible/screens/setup_screen.dart';
import 'package:simple_bible/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseModel>(
          create: (BuildContext context) => BaseModel(),
        )
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    BaseModel baseModel = Provider.of<BaseModel>(context);
    return MaterialApp(
      title: 'Place in Heart - My Bible',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: Color.fromRGBO(103, 33, 9, 1),
          labelColor: Color.fromRGBO(103, 33, 9, 1),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(246, 239, 209, 1),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromRGBO(103, 33, 9, 1),
          titleTextStyle: TextStyle(
            fontSize: 22 * baseModel.fontScale,
            color: const Color.fromRGBO(246, 239, 209, 1),
          ),
          iconTheme: const IconThemeData(
            color: Color.fromRGBO(246, 239, 209, 1),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash-screen',
      routes: <String, WidgetBuilder>{
        '/': (context) => const MainScreen(),
        '/setup': (context) => const SetupScreen(),
        '/splash-screen': (context) => const SplashScreen(),
        '/book': (context) => const BookScreen(),
        '/chapter': (context) => const ChapterScreen(),
      },
    );
  }
}
