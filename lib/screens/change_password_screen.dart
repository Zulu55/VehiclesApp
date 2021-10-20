import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Token token;

  ChangePasswordScreen({required this.token});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showLoader = false;
  bool _passwordShow = false;

  String _currentPassword = '';
  String _currentPasswordError = '';
  bool _currentPasswordShowError = false;
  TextEditingController _currentPasswordController = TextEditingController();

  String _newPassword = '';
  String _newPasswordError = '';
  bool _newPasswordShowError = false;
  TextEditingController _newPasswordController = TextEditingController();

  String _confirmPassword = '';
  String _confirmPasswordError = '';
  bool _confirmPasswordShowError = false;
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambio de contraseña'),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
                _showCurrentPassword(),
                _showNewPassword(),
                _showConfirmPassword(),
                _showButtons(),
            ],
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Widget _showCurrentPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Ingresa tu contraseña actual...',
          labelText: 'Contraseña actual',
          errorText: _currentPasswordShowError ? _currentPasswordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            }, 
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _currentPassword = value;
        },
      ),
    );
  }

  Widget _showNewPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Ingresa tu nueva contraseña...',
          labelText: 'Nueva contraseña',
          errorText: _newPasswordShowError ? _newPasswordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            }, 
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _newPassword = value;
        },
      ),
    );
  }

  Widget _showConfirmPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Ingresa la confirmación de la nueva contraseña...',
          labelText: 'Confirmación contraseña',
          errorText: _confirmPasswordShowError ? _confirmPasswordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            }, 
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _confirmPassword = value;
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
              child: Text('Cambiar Contraseña'),
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
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    _changePassword();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_currentPassword.length < 6) {
      isValid = false;
      _currentPasswordShowError = true;
      _currentPasswordError = 'Debes ingresar tu actual contraseña de al menos 6 carácteres.';
    } else {
      _currentPasswordShowError = false;
    }

    if (_newPassword.length < 6) {
      isValid = false;
      _newPasswordShowError = true;
      _newPasswordError = 'Debes ingresar tu nueva contraseña de al menos 6 carácteres.';
    } else {
      _newPasswordShowError = false;
    }

    if (_confirmPassword.length < 6) {
      isValid = false;
      _confirmPasswordShowError = true;
      _confirmPasswordError = 'Debes ingresar una confirmación de tu nueva contraseña de al menos 6 carácteres.';
    } else {
      _confirmPasswordShowError = false;
    }

    if (_confirmPassword != _newPassword) {
      isValid = false;
      _confirmPasswordShowError = true;
      _confirmPasswordError = 'La nueva contraseña y la confirmación, no son iguales.';
    } else {
      _confirmPasswordShowError = false;
    }

    setState(() { });
    return isValid;
  }

  void _changePassword() async {
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
      'oldPassword': _currentPassword,
      'newPassword': _newPassword,
      'confirm': _confirmPassword,
    };

    Response response = await ApiHelper.post(
      '/api/Account/ChangePassword', 
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

    await showAlertDialog(
      context: context,
      title: 'Confirmación', 
      message: 'Su contraseña ha sido cambiada con éxito.',
      actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
      ]
    );    

    Navigator.pop(context, 'yes');
  }
}