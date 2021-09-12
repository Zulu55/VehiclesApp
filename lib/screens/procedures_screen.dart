import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/procedure_screen.dart';

class ProceduresScreen extends StatefulWidget {
  final Token token;

  ProceduresScreen({required this.token});

  @override
  _ProceduresScreenState createState() => _ProceduresScreenState();
}

class _ProceduresScreenState extends State<ProceduresScreen> {
  List<Procedure> _procedures = [];
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procedimientos'),
      ),
      body: Center(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...') : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ProcedureScreen(
                token: widget.token, 
                procedure: Procedure(description: '', id: 0, price: 0),
              )
            )
          );
        },
      ),
    );
  }

  void _getProcedures() async {
    setState(() {
      _showLoader = true;
    });

    Response response = await ApiHelper.getProcedures(widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: response.message,
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    setState(() {
      _procedures = response.result;
    });
  }

  Widget _getContent() {
    return _procedures.length == 0 
      ? _noContent()
      : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'No hay procedimientos almacenados.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return ListView(
      children: _procedures.map((e) {
        return Card(
          child: InkWell(
            onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ProcedureScreen(
                  token: widget.token, 
                  procedure: e,
                )
              )
            );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.description, 
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(e.price)}', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}