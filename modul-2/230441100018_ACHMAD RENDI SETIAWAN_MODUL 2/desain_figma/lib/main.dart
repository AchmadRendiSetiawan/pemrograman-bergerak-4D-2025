import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wisata App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(), // Halaman awal
    );
  }
}
