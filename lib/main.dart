

import 'package:flutter/material.dart';
import 'package:tournament_client/example.dart';
import 'package:tournament_client/home.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: ExamplePage(data: [],)
      home: const MyHomePage(title: 'Tournament Client Page'),
    );
  }
}
