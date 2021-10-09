import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';

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
                _showModel(),
                _showPlaque(),
                _showLine(),
                _showColor(),
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
                borderRadius: BorderRadius.circular(80),
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
    return Container();
  }

  Widget _showBrand() {
    return Container();
  }

  Widget _showModel() {
    return Container();
  }

  Widget _showPlaque() {
    return Container();
  }

  Widget _showLine() {
    return Container();
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
}