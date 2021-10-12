import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/response.dart';

import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';

class HistoryScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;
  final History history;

  HistoryScreen({required this.token, required this.user, required this.vehicle, required this.history});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showLoader = false;

  String _remarks = '';
  String _remarksError = '';
  bool _remarksShowError = false;
  TextEditingController _remarksController = TextEditingController();

  String _mileage = '';
  String _mileageError = '';
  bool _mileageShowError = false;
  TextEditingController _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remarks = widget.history.remarks!;
    _remarksController.text = _remarks;
    _mileage = widget.history.mileage.toString();
    _mileageController.text = _mileage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.history.id == 0 
            ? 'Nueva historia' 
            : 'Editar historia'
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _showRemarks(),
              _showMileage(),
              _showButtons(),
            ],
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Widget _showRemarks() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 4,
        controller: _remarksController,
        decoration: InputDecoration(
          hintText: 'Ingresa un comentario...',
          labelText: 'Comentario',
          errorText: _remarksShowError ? _remarksError : null,
          suffixIcon: Icon(Icons.description),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _remarks = value;
        },
      ),
    );
  }

  Widget _showMileage() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _mileageController,
        decoration: InputDecoration(
          hintText: 'Ingresa un kilometraje...',
          labelText: 'Kilometraje',
          errorText: _mileageShowError ? _mileageError : null,
          suffixIcon: Icon(Icons.directions_car),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _mileage = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text('Guardar'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFF120E43);
                  }
                ),
              ),
              onPressed: () => _save(), 
            ),
          ),
          widget.history.id == 0 
            ? Container() 
            : SizedBox(width: 20,),
          widget.history.id == 0 
            ? Container() 
            : Expanded(
                child: ElevatedButton(
                  child: Text('Borrar'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Color(0xFFB4161B);
                      }
                    ),
                  ),
                  onPressed: () => _confirmDelete(), 
              ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.history.id == 0 ? _addRecord() : _saveRecord();
  }

  void _confirmDelete() async {
    var response =  await showAlertDialog(
      context: context,
      title: 'Confirmación', 
      message: '¿Estas seguro de querer borrar el registro?',
      actions: <AlertDialogAction>[
          AlertDialogAction(key: 'no', label: 'No'),
          AlertDialogAction(key: 'yes', label: 'Sí'),
      ]
    );    

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
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

    Response response = await ApiHelper.delete(
      '/api/Histories/', 
      widget.history.id.toString(), 
      widget.token
    );

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

    Navigator.pop(context, 'yes');
  }

  bool _validateFields() {
    bool isValid = true;

    if (_remarks.isEmpty) {
      isValid = false;
      _remarksShowError = true;
      _remarksError = 'Debes ingresar un comentario.';
    } else {
      _remarksShowError = false;
    }

    if (_mileage.isEmpty) {
      isValid = false;
      _mileageShowError = true;
      _mileageError = 'Debes ingresar un kilometraje.';
    } else {
      int mileage = int.parse(_mileage);
      if (mileage <= 0) {
        isValid = false;
        _mileageShowError = true;
        _mileageError = 'Debes ingresar un kilometraje mayor a cero.';
      } else {
        _mileageShowError = false;
      }
    }

    setState(() { });
    return isValid;
  }

  void _addRecord() async {
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

    Map<String, dynamic> request = {
      'vehicleId': widget.vehicle.id,
      'mileage': int.parse(_mileage),
      'remarks': _remarks,
    };

    Response response = await ApiHelper.post(
      '/api/Histories/', 
      request, 
      widget.token
    );

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

    Navigator.pop(context, 'yes');
  }

  void _saveRecord() async {
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

    Map<String, dynamic> request = {
      'id': widget.history.id,
      'vehicleId': widget.vehicle.id,
      'mileage': int.parse(_mileage),
      'remarks': _remarks,
    };

    Response response = await ApiHelper.put(
      '/api/Histories/', 
      widget.history.id.toString(), 
      request, 
      widget.token
    );

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

    Navigator.pop(context, 'yes');
  }
}