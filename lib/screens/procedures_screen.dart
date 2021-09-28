import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
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
  bool _isFiltered = false;
  String _search = '';

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
        actions: <Widget>[
          _isFiltered
          ? IconButton(
              onPressed: _removeFilter, 
              icon: Icon(Icons.filter_none)
            )
          : IconButton(
              onPressed: _showFilter, 
              icon: Icon(Icons.filter_alt)
            )
        ],
      ),
      body: Center(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...') : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getProcedures() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Response response = await ApiHelper.getProcedures(widget.token);

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
          _isFiltered
          ? 'No hay procedimientos con ese criterio de búsqueda.'
          : 'No hay procedimientos registrados.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getProcedures,
      child: ListView(
        children: _procedures.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
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
      ),
    );
  }

  void _showFilter() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Filtrar Procedimientos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras del procedimiento'),
              SizedBox(height: 10,),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Criterio de búsqueda...',
                  labelText: 'Buscar',
                  suffixIcon: Icon(Icons.search)
                ),
                onChanged: (value) {
                  _search = value;
                },
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text('Cancelar')
            ),
            TextButton(
              onPressed: () => _filter(), 
              child: Text('Filtrar')
            ),
          ],
        );
      });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getProcedures();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Procedure> filteredList = [];
    for (var procedure in _procedures) {
      if (procedure.description.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(procedure);
      }
    }

    setState(() {
      _procedures = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ProcedureScreen(
          token: widget.token, 
          procedure: Procedure(description: '', id: 0, price: 0),
        )
      )
    );
    if (result == 'yes') {
      _getProcedures();
    }
  }

  void _goEdit(Procedure procedure) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ProcedureScreen(
          token: widget.token, 
          procedure: procedure,
        )
      )
    );
    if (result == 'yes') {
      _getProcedures();
    }
  }
}