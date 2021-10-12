import 'dart:convert';
import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/models/vehicle_type.dart';
import 'package:vehicles_app/screens/take_picture_screen.dart';

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
  int _current = 0;
  CarouselController _carouselController = CarouselController();

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

  String _color = '';
  String _colorError = '';
  bool _colorShowError = false;
  TextEditingController _colorController = TextEditingController();

  String _model = '';
  String _modelError = '';
  bool _modelShowError = false;
  TextEditingController _modelController = TextEditingController();

  String _plaque = '';
  String _plaqueError = '';
  bool _plaqueShowError = false;
  TextEditingController _plaqueController = TextEditingController();

  String _remarks = '';
  String _remarksError = '';
  bool _remarksShowError = false;
  TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
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
    return widget.vehicle.id == 0
      ? _showUniquePhoto()
      : _showPhotosCarousel();
  }

  Widget _showUniquePhoto() {
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
                : CachedNetworkImage(
                    imageUrl: widget.vehicle.imageFullPath,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    height: 160,
                    width: 160,
                    placeholder: (context, url) => Image(
                      image: AssetImage('assets/vehicles_logo.png'),
                      fit: BoxFit.cover,
                      height: 160,
                      width: 160,
                    ),
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
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _modelController,
        decoration: InputDecoration(
          hintText: 'Ingresa model...',
          labelText: 'Modelo',
          errorText: _modelShowError ? _modelError : null,
          suffixIcon: Icon(Icons.event),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _model = value;
        },
      ),
    );
  }

  Widget _showPlaque() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _plaqueController,
        decoration: InputDecoration(
          hintText: 'Ingresa placa...',
          labelText: 'Placa',
          errorText: _plaqueShowError ? _plaqueError : null,
          suffixIcon: Icon(Icons.directions_car),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _plaque = value;
        },
      ),
    );
  }

  Widget _showLine() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
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
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _colorController,
        decoration: InputDecoration(
          hintText: 'Ingresa color...',
          labelText: 'Color',
          errorText: _colorShowError ? _colorError : null,
          suffixIcon: Icon(Icons.palette),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _color = value;
        },
      ),
    );
  }

  Widget _showRemarks() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _remarksController,
        decoration: InputDecoration(
          hintText: 'Ingresa comentarios...',
          labelText: 'Comentarios',
          errorText: _remarksShowError ? _remarksError : null,
          suffixIcon: Icon(Icons.notes),
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
          widget.vehicle.id == 0 
            ? Container() 
            : SizedBox(width: 20,),
          widget.vehicle.id == 0 
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

  Future<Null> _takePicture() async {
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

  Future<Null> _selectPicture() async {
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

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.vehicle.id == 0 ? _addRecord() : _saveRecord();
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
      '/api/Vehicles/', 
      widget.vehicle.id.toString(), 
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

    if (_vehicleTypeId == 0) {
      isValid = false;
      _vehicleTypeIdShowError = true;
      _vehicleTypeIdError = 'Debes seleccionar un tipo de vehículo.';
    } else {
      _vehicleTypeIdShowError = false;
    }

    if (_brandId == 0) {
      isValid = false;
      _brandIdShowError = true;
      _brandIdError = 'Debes seleccionar una marca.';
    } else {
      _brandIdShowError = false;
    }

    if (_line.isEmpty) {
      isValid = false;
      _lineShowError = true;
      _lineError = 'Debes ingresar una línea.';
    } else {
      _lineShowError = false;
    }

    if (_color.isEmpty) {
      isValid = false;
      _colorShowError = true;
      _colorError = 'Debes ingresar un color.';
    } else {
      _colorShowError = false;
    }

    if (_model.isEmpty) {
      isValid = false;
      _modelShowError = true;
      _modelError = 'Debes ingresar un modelo.';
    } else {
      int model = int.parse(_model);
      if (model < 1900 || model > 3000) {
        isValid = false;
        _modelShowError = true;
        _modelError = 'El modelo debe ser un número entre 1900 y 3000.';
      } else {
        _modelShowError = false;
      }
    }

    if (!RegExp('[a-zA-Z]{3}[0-9]{2}[a-zA-Z0-9]').hasMatch(_plaque)) {
      isValid = false;
      _plaqueShowError = true;
      _plaqueError = 'El formato de la placa es incorrecto.';
    } else {
      _plaqueShowError = false;
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

    String base64Image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'vehicleTypeId': _vehicleTypeId,
      'brandId': _brandId,
      'model': _model,
      'plaque': _plaque.toUpperCase(),
      'line': _line,
      'color': _color,
      'userId': widget.user.id,
      'remarks': _remarks,
      'image': base64Image,
    };

    Response response = await ApiHelper.post(
      '/api/Vehicles/', 
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
      'id' : widget.vehicle.id,
      'vehicleTypeId': _vehicleTypeId,
      'brandId': _brandId,
      'model': _model,
      'plaque': _plaque.toUpperCase(),
      'line': _line,
      'color': _color,
      'userId': widget.user.id,
      'remarks': _remarks,
    };

    Response response = await ApiHelper.put(
      '/api/Vehicles/', 
      widget.vehicle.id.toString(),
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

  void _loadFieldValues() {
    _vehicleTypeId = widget.vehicle.vehicleType.id;
    _brandId = widget.vehicle.brand.id;

    _model = widget.vehicle.model.toString();
    _modelController.text = _model;   

    _plaque = widget.vehicle.plaque;
    _plaqueController.text = _plaque;   

    _line = widget.vehicle.line;
    _lineController.text = _line;   

    _color = widget.vehicle.color;
    _colorController.text = _color;   

    _remarks = widget.vehicle.remarks == null ? '' : widget.vehicle.remarks!;
    _remarksController.text = _remarks;   
  }

  Widget _showPhotosCarousel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }
            ),
            carouselController: _carouselController,
            items: widget.vehicle.vehiclePhotos.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child:  ClipRRect(
                       borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: i.imageFullPath,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        height: 300,
                        width: 300,
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/vehicles_logo.png'),
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        ),
                      ),
                    )
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.vehicle.vehiclePhotos.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
          _showImageButtons()        
        ],
      ),
    );
  }

  void _loadData() async {
    await _getVehiclesTypes();
    await _getBrands();
    _loadFieldValues();
  }

  Widget _showImageButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.add_a_photo),
                  Text('Adicionar Foto'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFF120E43);
                  }
                ),
              ),
              onPressed: () => _goAddPhoto(), 
            ),
          ),
          SizedBox(width: 20,),
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.delete),
                  Text('Eliminar Foto'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFFB4161B);
                  }
                ),
              ),
              onPressed: () => _confirmDeletePhoto(), 
            ),
          ),
        ],
      ),
    );
  }

  void _goAddPhoto() async {
    var response = await showAlertDialog(
      context: context,
      title: 'Confirmación', 
      message: '¿De donde deseas obtener la imagen?',
      actions: <AlertDialogAction>[
          AlertDialogAction(key: 'cancel', label: 'Cancelar'),
          AlertDialogAction(key: 'camera', label: 'Cámara'),
          AlertDialogAction(key: 'gellery', label: 'Imágenes'),
      ]
    );   

    if (response == 'cancel') {
      return;
    } 

    if (response == 'camera') {
      await _takePicture();
    } else {
      await _selectPicture();
    }

    if (_photoChanged) {
      _addPicture();
    }
  }

  void _confirmDeletePhoto() async {
    var response =  await showAlertDialog(
      context: context,
      title: 'Confirmación', 
      message: '¿Estas seguro de querer borrar la última foto tomada?',
      actions: <AlertDialogAction>[
          AlertDialogAction(key: 'no', label: 'No'),
          AlertDialogAction(key: 'yes', label: 'Sí'),
      ]
    );    

    if (response == 'yes') {
      _deletePhoto();
    }
  }

  void _addPicture() async {
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

    List<int> imageBytes = await _image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> request = {
      'vehicleId': widget.vehicle.id,
      'image': base64Image
    };

    Response response = await ApiHelper.post(
      '/api/VehiclePhotoes',
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

  void _deletePhoto() async {
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
      '/api/VehiclePhotoes/', 
      widget.vehicle.vehiclePhotos[widget.vehicle.vehiclePhotos.length - 1].id.toString(), 
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