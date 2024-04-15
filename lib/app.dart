import 'package:firebase_storage_apps/screen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Storage App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
        ),
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
