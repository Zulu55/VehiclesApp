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

  _save() {}

  _confirmDelete() {}

  void _loadFieldValues() {
    _procedureId = widget.detail.procedure.id;
    
    _remarks = widget.detail.remarks!;
    _remarksController.text = _remarks;
    
    _laborPrice = widget.detail.laborPrice.toString();
    _laborPriceController.text = _laborPrice;
    
    _sparePartsPrice = widget.detail.sparePartsPrice.toString();
    _sparePartsPriceController.text = _sparePartsPrice;
  }
}