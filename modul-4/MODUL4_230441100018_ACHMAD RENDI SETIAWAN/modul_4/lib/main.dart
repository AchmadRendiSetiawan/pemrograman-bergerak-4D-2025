import 'package:flutter/material.dart';
import 'screens/list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
