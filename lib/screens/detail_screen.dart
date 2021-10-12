import 'package:flutter/material.dart';
import 'package:vehicles_app/models/detail.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';

class DetailScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;
  final History history;
  final Detail detail;

  DetailScreen({required this.token, required this.user, required this.vehicle, required this.history, required this.detail});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: Center(
        child: Text('Detail'),
      ),
    );
  }
}