import 'package:flutter/material.dart';
import 'package:vehicles_app/screens/login_screen.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicles App',
      home: LoginScreen(),
    );
  }
}