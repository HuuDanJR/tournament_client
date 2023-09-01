

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tournament_client/chart.dart';
import 'package:tournament_client/example.dart';
import 'package:tournament_client/home.dart';
import 'package:tournament_client/home2.dart';
import 'package:tournament_client/race_chart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tournament Client',
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: false,
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: GoogleFonts.latoTextTheme(
        Theme.of(context).textTheme,
    ),
      ),
      // home: MyHomePage2(title: 'text',),
      // home: BarCharRace(),
      home:MyHomePage(title: 'homepage',),
      // home: const MyHomePage2(title: 'Tournament Client'),
      // home:ExamplePage()
    );
  }
}
