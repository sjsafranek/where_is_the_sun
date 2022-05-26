import 'package:flutter/material.dart';
import 'package:where_is_the_sun/shared/map_widget.dart';
import 'package:where_is_the_sun/screens/find_screen.dart';
import 'package:where_is_the_sun/screens/intro_screen.dart';

void main() {
  runApp(const WhereIsTheSunApp());
}

class WhereIsTheSunApp extends StatelessWidget {
  const WhereIsTheSunApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Where is the Sun?',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        '/': (context) => const IntroScreen(),
        '/find': (context) => const FindScreen(),
        //'/favorites' (context) => FavoritesScreen()
      },
      initialRoute: '/',
    );
  }
}