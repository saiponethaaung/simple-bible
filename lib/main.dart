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
      child: MaterialApp(
        title: 'Place in Heart - My Bible',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/splash-screen',
        routes: <String, WidgetBuilder>{
          '/': (context) => const MainScreen(),
          '/setup': (context) => const SetupScreen(),
          '/splash-screen': (context) => const SplashScreen(),
          '/book': (context) => BookScreen(),
          '/chapter': (context) => ChapterScreen(),
        },
      ),
    );
  }
}
