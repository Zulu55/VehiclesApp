import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/detail.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
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
  bool _showLoader = false;

  int _procedureId = 0;
  String _procedureIdError = '';
  bool _procedureIdShowError = false;
  List<Procedure> _procedures = [];

  String _remarks = '';
  String _remarksError = '';
  bool _remarksShowError = false;
  TextEditingController _remarksController = TextEditingController();

  String _laborPrice = '';
  String _laborPriceError = '';
  bool _laborPriceShowError = false;
  TextEditingController _laborPriceController = TextEditingController();

  String _sparePartsPrice = '';
  String _sparePartsPriceError = '';
  bool _sparePartsPriceShowError = false;
  TextEditingController _sparePartsPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getProcedures();
    _loadFieldValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.detail.id == 0
            ? 'Nuevo procedimiento' 
            : widget.detail.procedure.description
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showProcedure(),
                _showRemarks(),
                _showLaborPrice(),
                _showSparePartsPrice(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
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

  Widget _showProcedure() {
    return Container(
      padding: EdgeInsets.all(10),
      child: _procedures.length == 0 
        ? Text('Cargando procedimientos...')
        : DropdownButtonFormField(
            items: _getComboProcedures(),
            value: _procedureId,
            onChanged: (option) {
              setState(() {
                _procedureId = option as int;
                _laborPrice = _getPrice(_procedureId).toString();
                _laborPriceController.text = _laborPrice;
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione un procedimiento...',
              labelText: 'Procedimiento',
              errorText: _procedureIdShowError ? _procedureIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }

  Widget _showRemarks() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
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

  Widget _showLaborPrice() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: _laborPriceController,
        decoration: InputDecoration(
          hintText: 'Ingresa valor de la mano de obra...',
          labelText: 'Valor mano de obra',
          errorText: _laborPriceShowError ? _laborPriceError : null,
          suffixIcon: Icon(Icons.build),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _laborPrice = value;
        },
      ),
    );
  }

  Widget _showSparePartsPrice() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: _sparePartsPriceController,
        decoration: InputDecoration(
          hintText: 'Ingresa valor de los repuestos...',
          labelText: 'Valor repuestos',
          errorText: _sparePartsPriceShowError ? _sparePartsPriceError : null,
          suffixIcon: Icon(Icons.attach_money),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _sparePartsPrice = value;
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
          widget.detail.id == 0 
            ? Container() 
            : SizedBox(width: 20,),
          widget.detail.id == 0 
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

  List<DropdownMenuItem<int>> _getComboProcedures() {
    List<DropdownMenuItem<int>> list = [];
    
    list.add(DropdownMenuItem(
      child: Text('Seleccione un procedimiento...'),
      value: 0,
    ));

    _procedures.forEach((documnentType) { 
      list.add(DropdownMenuItem(
        child: Text(documnentType.description),
        value: documnentType.id,
      ));
    });

    return list;
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.detail.id == 0 ? _addRecord() : _saveRecord();
  }

  void _loadFieldValues() {
    _procedureId = widget.detail.procedure.id;
    
    _remarks = widget.detail.remarks!;
    _remarksController.text = _remarks;
    
    _laborPrice = widget.detail.laborPrice.toString();
    _laborPriceController.text = _laborPrice;
    
    _sparePartsPrice = widget.detail.sparePartsPrice.toString();
    _sparePartsPriceController.text = _sparePartsPrice;
  }

  bool _validateFields() {
    bool isValid = true;

    if (_procedureId == 0) {
      isValid = false;
      _procedureIdShowError = true;
      _procedureIdError = 'Debes seleccionar un procedimiento.';
    } else {
      _procedureIdShowError = false;
    }

    if (_remarks.isEmpty) {
      isValid = false;
      _remarksShowError = true;
      _remarksError = 'Debes de ingresar un comentario.';
    } else {
      _remarksShowError = false;
    }

    if (_laborPrice.isEmpty) {
      isValid = false;
      _laborPriceShowError = true;
      _laborPriceError = 'Debes ingresar un valor de mano de obra.';
    } else {
      double laborPrice = double.parse(_laborPrice);
      if (laborPrice < 0) {
        isValid = false;
        _laborPriceShowError = true;
      _laborPriceError = 'Debes ingresar un valor de mano de obra positivo.';
      } else {
        _laborPriceShowError = false;
      }
    }

    if (_sparePartsPrice.isEmpty) {
      isValid = false;
      _sparePartsPriceShowError = true;
      _sparePartsPriceError = 'Debes ingresar un valor de repuestos.';
    } else {
      double sparePartsPrice = double.parse(_sparePartsPrice);
      if (sparePartsPrice < 0) {
        isValid = false;
        _sparePartsPriceShowError = true;
        _sparePartsPriceError = 'Debes ingresar un valor de repuestos positivo.';
      } else {
        _sparePartsPriceShowError = false;
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
      'historyId': widget.history.id,
      'procedureId': _procedureId,
      'laborPrice': int.parse(_laborPrice),
      'sparePartsPrice': int.parse(_sparePartsPrice),
      'remarks': _remarks,
    };

    Response response = await ApiHelper.post(
      '/api/Details/', 
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
      'id': widget.detail.id,
      'historyId': widget.history.id,
      'procedureId': _procedureId,
      'laborPrice': int.parse(_laborPrice),
      'sparePartsPrice': int.parse(_sparePartsPrice),
      'remarks': _remarks,
    };

    Response response = await ApiHelper.put(
      '/api/Details/', 
      widget.detail.id.toString(), 
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
      '/api/Details/', 
      widget.detail.id.toString(), 
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

  int _getPrice(int procedureId) {
    var procedures = _procedures.where((p) => p.id == procedureId).toList();
    String priceString = procedures[0].price.toString();
    return int.parse(priceString.substring(0, priceString.length - 2));
  }
}