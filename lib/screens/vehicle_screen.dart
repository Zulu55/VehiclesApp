import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/models/vehicle_type.dart';

import 'take_picture_screen.dart';

class VehicleScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;

  VehicleScreen({required this.token, required this.user, required this.vehicle});

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  bool _showLoader = false;
  bool _photoChanged = false;
  late XFile _image;

  int _vehicleTypeId = 0;
  String _vehicleTypeIdError = '';
  bool _vehicleTypeIdShowError = false;
  List<VehicleType> _vehicleTypes = [];

  int _brandId = 0;
  String _brandIdError = '';
  bool _brandIdShowError = false;
  List<Brand> _brands = [];

  String _line = '';
  String _lineError = '';
  bool _lineShowError = false;
  TextEditingController _lineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getVehiclesTypes();
    _getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle.id == 0
            ? 'Nuevo vehiculo' 
            : '${widget.vehicle.brand.description} ${widget.vehicle.line} ${widget.vehicle.plaque}'
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showPhoto(),
                _showVehicleType(),
                _showBrand(),
                _showLine(),
                _showColor(),
                _showModel(),
                _showPlaque(),
                _showRemarks(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Widget _showPhoto() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10),
          child: widget.vehicle.id == 0 && !_photoChanged
            ? Image(
                image: AssetImage('assets/noimage.png'),
                height: 160,
                width: 160,
                fit: BoxFit.cover,
              ) 
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _photoChanged 
                ? Image.file(
                    File(_image.path),
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ) 
                : FadeInImage(
                    placeholder: AssetImage('assets/vehicles_logo.png'), 
                    image: NetworkImage(widget.vehicle.imageFullPath),
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover
                  ),
              ),        
        ),
        Positioned(
          bottom: 0,
          left: 100,
          child: InkWell(
            onTap: () => _takePicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: Icon(
                  Icons.photo_camera,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () => _selectPicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ),
      ] 
    );
  }

  Widget _showVehicleType() {
    return Container(
      padding: EdgeInsets.all(10),
      child: _vehicleTypes.length == 0 
        ? Text('Cargando tipos de vehículos...')
        : DropdownButtonFormField(
            items: _getComboVehicleTypes(),
            value: _vehicleTypeId,
            onChanged: (option) {
              setState(() {
                _vehicleTypeId = option as int;
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione un tipo de vehículo...',
              labelText: 'Tipo vehículo',
              errorText: _vehicleTypeIdShowError ? _vehicleTypeIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }

  Widget _showBrand() {
    return Container(
      padding: EdgeInsets.all(10),
      child: _vehicleTypes.length == 0 
        ? Text('Cargando marcas de vehículos...')
        : DropdownButtonFormField(
            items: _getComboBrands(),
            value: _brandId,
            onChanged: (option) {
              setState(() {
                _brandId = option as int;
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione una marca...',
              labelText: 'Marca',
              errorText: _brandIdShowError ? _brandIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }

  Widget _showModel() {
    return Container();
  }

  Widget _showPlaque() {
    return Container();
  }

  Widget _showLine() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _lineController,
        decoration: InputDecoration(
          hintText: 'Ingresa línea...',
          labelText: 'Línea',
          errorText: _lineShowError ? _lineError : null,
          suffixIcon: Icon(Icons.directions_car_filled),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _line = value;
        },
      ),
    );
  }

  Widget _showColor() {
    return Container();
  }

  Widget _showRemarks() {
    return Container();
  }

  Widget _showButtons() {
    return Container();
  }

  void _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Response? response = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera,)
      )
    );
    if (response != null) {
      setState(() {
          _photoChanged = true;
          _image = response.result;
      });
    }
  }

  void _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  Future<Null> _getVehiclesTypes() async {
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

    Response response = await ApiHelper.getVehicleTypes(widget.token);

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
      _vehicleTypes = response.result;
    });
  }

  List<DropdownMenuItem<int>> _getComboVehicleTypes() {
    List<DropdownMenuItem<int>> list = [];
    
    list.add(DropdownMenuItem(
      child: Text('Seleccione un tipo de vehículo...'),
      value: 0,
    ));

    _vehicleTypes.forEach((vehicleType) { 
      list.add(DropdownMenuItem(
        child: Text(vehicleType.description),
        value: vehicleType.id,
      ));
    });

    return list;
  }

  List<DropdownMenuItem<int>> _getComboBrands() {
    List<DropdownMenuItem<int>> list = [];
    
    list.add(DropdownMenuItem(
      child: Text('Seleccione una marca...'),
      value: 0,
    ));

    _brands.forEach((brand) { 
      list.add(DropdownMenuItem(
        child: Text(brand.description),
        value: brand.id,
      ));
    });

    return list;
  }

  Future<Null> _getBrands() async {
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

    Response response = await ApiHelper.getBrands(widget.token);

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
      _brands = response.result;
    });
  }
}