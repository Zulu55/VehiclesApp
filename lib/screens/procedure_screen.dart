import 'package:flutter/material.dart';

import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/token.dart';

class ProcedureScreen extends StatefulWidget {
  final Token token;
  final Procedure procedure;

  ProcedureScreen({required this.token, required this.procedure});

  @override
  _ProcedureScreenState createState() => _ProcedureScreenState();
}

class _ProcedureScreenState extends State<ProcedureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.procedure.id == 0 
            ? 'Nuevo procedimiento' 
            : widget.procedure.description
        ),
      ),
      body: Center(
        child: Text(
          widget.procedure.id == 0 
            ? 'Nuevo procedimiento' 
            : widget.procedure.description
        ),
      ),
    );
  }
}