import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/document_types_screen.dart';
import 'package:vehicles_app/screens/login_screen.dart';
import 'package:vehicles_app/screens/procedures_screen.dart';
import 'package:vehicles_app/screens/user_info_screen.dart';
import 'package:vehicles_app/screens/user_screen.dart';
import 'package:vehicles_app/screens/users_screen.dart';
import 'package:vehicles_app/screens/vehicle_types_screen.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'brands_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicles'),
      ),
      body: _getBody(),
      drawer: widget.token.user.userType == 0 
        ? _getMechanicMenu() 
        : _getCustomerMenu(),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: CachedNetworkImage(
                imageUrl: widget.token.user.imageFullPath,
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
              )
            ),
            SizedBox(height: 30,),
            Center(
              child: Text(
                'Bienvenid@ ${widget.token.user.fullName}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Llamar al taller'),
              SizedBox(width: 10,),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.call, color: Colors.white,),
                    onPressed: () => launch("tel://3223114620"), 
                  ),
                ),
              )
            ],
          ),       
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Enviar mensaje al taller'),
              SizedBox(width: 10,),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.green,
                  child: IconButton(
                    icon: Icon(Icons.insert_comment, color: Colors.white,),
                    onPressed: () => _sendMessage(), 
                  ),
                ),
              )
            ],
          ),       
          ],
        ),
      ),
    );
  }

  Widget _getMechanicMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Image(
              image: AssetImage('assets/vehicles_logo.png'),
            )
          ),
          ListTile(
            leading: Icon(Icons.two_wheeler),
            title: const Text('Marcas'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => BrandsScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.precision_manufacturing),
            title: const Text('Procedimientos'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ProceduresScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.badge),
            title: const Text('Tipos de Documento'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => DocumentTypesScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.toys),
            title: const Text('Tipos de Vehículos'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => VehicleTypesScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UsersScreen(token: widget.token,)
                )
              );
            },
          ),
          Divider(
            color: Colors.black, 
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: const Text('Editar Perfil'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserScreen(
                    token: widget.token, 
                    user: widget.token.user, 
                    myProfile: true,
                  )
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  Widget _getCustomerMenu() {
     return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Image(
              image: AssetImage('assets/vehicles_logo.png'),
            )
          ),
          ListTile(
            leading: Icon(Icons.two_wheeler),
            title: const Text('Mis Vehículos'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserInfoScreen(
                    token: widget.token, 
                    user: widget.token.user, 
                    isAdmin: false, 
                  )
                )
              );
            },
          ),
          Divider(
            color: Colors.black, 
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: const Text('Editar Perfil'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserScreen(
                    token: widget.token, 
                    user: widget.token.user, 
                    myProfile: true,
                  )
                )
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => LoginScreen()
      )
    ); 
  }

  void _sendMessage() async {
    final link = WhatsAppUnilink(
      phoneNumber: '3223114620',
      text: 'Hola soy ${widget.token.user.fullName} cliente del taller',
    );
    await launch('$link');
  }
}