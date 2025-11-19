import 'package:flutter/material.dart';
import 'package:lc_eye_project/LC-Eye/pages/MainPage.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectInfoPage.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectListPage.dart';

void main() {
  runApp(MyApp());
}// f end

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LC-Eye App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      initialRoute: "/",
      routes: {
        "/" : (context) => MainPage(),
      }
    );
  }// f end
}// class end
