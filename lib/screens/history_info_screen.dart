import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:vehicles_app/screens/detail_screen.dart';

class HistoryInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;
  final History history;

  HistoryInfoScreen({required this.token, required this.user, required this.vehicle, required this.history});

  @override
  _HistoryInfoScreenState createState() => _HistoryInfoScreenState();
}

class _HistoryInfoScreenState extends State<HistoryInfoScreen> {
  bool _showLoader = false;
  late History _history;

  @override
  void initState() {
    super.initState();
    _history = widget.history;
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAddDetail(Detail(
          id: 0, 
          procedure: Procedure(id: 0, description: '', price: 0), 
          laborPrice: 0, 
          sparePartsPrice: 0, 
          totalPrice: 0, 
          remarks: '')),
      ),
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

  void _goAddDetail(Detail detail) async {
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
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: widget.vehicle.imageFullPath,
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
                  onTap: () => _goEdit(),
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
            child: Container(
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
                              widget.vehicle.vehicleType.description, 
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
                              widget.vehicle.brand.description, 
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
                              widget.vehicle.model.toString(), 
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
                              widget.vehicle.plaque, 
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
                              widget.vehicle.line, 
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
                              widget.vehicle.color, 
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
                              widget.vehicle.remarks == null ? 'NA' : widget.vehicle.remarks!, 
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
                              widget.vehicle.historiesCount.toString(), 
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
          ),
        ],
      ),
    );
  }

  Widget _getListView() {
    return Container(

    );
  }

  Widget _noContent() {
    return Container(

    );
  }

  Widget _goEdit() {
    return Container(

    );
  }
}