import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/detail.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/screens/detail_screen.dart';
import 'package:vehicles_app/screens/history_screen.dart';
import 'package:vehicles_app/screens/vehicle_screen.dart';

class HistoryInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;
  final History history;
  final bool isAdmin;

  HistoryInfoScreen({required this.token, required this.user, required this.vehicle, required this.history, required this.isAdmin});

  @override
  _HistoryInfoScreenState createState() => _HistoryInfoScreenState();
}

class _HistoryInfoScreenState extends State<HistoryInfoScreen> {
  bool _showLoader = false;
  late History _history;
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
    _vehicle = widget.vehicle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.brand.description} ${widget.vehicle.line} ${widget.vehicle.plaque}'),
      ),
      body: Center(
        child: _showLoader 
          ? LoaderComponent(text: 'Por favor espere...',) 
          : _getContent(),
      ),
      floatingActionButton: widget.isAdmin 
        ? FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _goDetail(Detail(
              id: 0, 
              procedure: Procedure(id: 0, description: '', price: 0), 
              laborPrice: 0, 
              sparePartsPrice: 0, 
              totalPrice: 0, 
              remarks: '')),
          )
        : Container()
    );
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showVehicleInfo(),
        Expanded(
          child: _history.details.length == 0 ? _noContent() : _getListView(),
        ),
      ],
    );
  }

  void _goDetail(Detail detail) async {
    if (!widget.isAdmin) {
      return;
    }

    String? result = await  Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          token: widget.token, 
          user: widget.user, 
          vehicle: widget.vehicle, 
          history: widget.history, 
          detail: detail,
        ) 
      )
    );
    if (result == 'yes') {
      await _getHistory();
    }
  }

  Future<Null> _getHistory() async {
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

    Response response = await ApiHelper.getHistory(widget.token, widget.history.id.toString());

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
      _history = response.result;
    });
  }

  Widget _showVehicleInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      imageUrl: _vehicle.imageFullPath,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                      placeholder: (context, url) => Image(
                        image: AssetImage('assets/vehicles_logo.png'),
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 60,
                    child: InkWell(
                      onTap: () => _goEditVehicle(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: Colors.green[50],
                          height: 40,
                          width: 40,
                          child: Icon(
                            Icons.edit,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                  )
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Tipo de vehículo: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.vehicleType.description, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Marca: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.brand.description, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Modelo: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.model.toString(), 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Placa: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.plaque, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Línea: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.line, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Color: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.color, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Comentarios: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.remarks == null ? 'NA' : widget.vehicle.remarks!, 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '# Historias: ', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                      _vehicle.historiesCount.toString(), 
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Column(
                children: <Widget>[
                  SizedBox(height: 5,),
                  Divider(
                    color: Colors.black, 
                    height: 2,
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text(
                        'Descripción: ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        _history.remarks == null ? 'NA' : _history.remarks!, 
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text(
                        'Kilometraje: ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        _history.mileage.toString(), 
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text(
                        'Valor Repuestos: ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(_history.totalSpareParts)}', 
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text(
                        'Valor Mano Obra: ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(_history.totalLabor)}', 
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text(
                        'Valor Total: ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(_history.total)}', 
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              widget.isAdmin 
                ? Positioned(
                  bottom: 0,
                  left: 280,
                  child: InkWell(
                    onTap: () => _goEditHistory(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: Colors.green[50],
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )
                )
              : Container()
            ],
          ),
        ],
      ),
    );
  }

  Widget _getListView() {
    return ListView(
      children: _history.details.map((e) {
        return Card(
          child: InkWell(
            onTap: () => _goDetail(e),
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                e.procedure.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                e.remarks == null ? 'NA' : e.remarks!,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Mano de obra: ${NumberFormat.currency(symbol: '\$').format(e.laborPrice)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Repuestos: ${NumberFormat.currency(symbol: '\$').format(e.sparePartsPrice)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Total: ${NumberFormat.currency(symbol: '\$').format(e.totalPrice)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  widget.isAdmin 
                    ? Icon(Icons.arrow_forward_ios, size: 40,)
                    : Container()
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'La historia no tiene detalles registrados.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _goEditHistory() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          token: widget.token, 
          user: widget.user, 
          vehicle: widget.vehicle, 
          history: _history, 
        )
      )
    );
    if (result == 'yes') {
      await _getHistory();
    }
  }

  void _goEditVehicle() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => VehicleScreen(
          token: widget.token, 
          user: widget.user, 
          vehicle: widget.vehicle, 
        )
      )
    );
    if (result == 'yes') {
      await _getVehicle();
    }
  }

  Future<Null> _getVehicle() async {
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

    Response response = await ApiHelper.getVehicle(widget.token, _vehicle.id.toString());

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
      _vehicle = response.result;
    });
  }
}