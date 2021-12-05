import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:login_google/helpers/constans.dart';
import 'package:login_google/models/record.dart';
import 'package:login_google/models/token.dart';
import 'package:login_google/screens/record_screen.dart';
import 'package:login_google/screens/records_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showLogo(),
            SizedBox(height: 20),
            _showGoogleLoginButton(),
          ],
        ),
      ),      
    );
  }

 Widget _showLogo() {
   return Image(
     image: AssetImage('assets/logo.png'),
     width: 120,
   );
 }

 Widget _showGoogleLoginButton() {
   return Container(
     margin: EdgeInsets.only(left: 10, right: 10),
     child: Row(
       children: <Widget>[
         Expanded(
           child: ElevatedButton.icon(
             onPressed: () => _loginGoogle(),
             icon: FaIcon(FontAwesomeIcons.google),
             label: Text('Iniciar sesión con Google'),
           )
         )
       ],
     )
   );
 }

 void _loginGoogle() async{
   setState(() {
     _showLoader = true;
   });

   var googleSignIn = GoogleSignIn();
   await googleSignIn.signOut();
   var user = await googleSignIn.signIn();

   if (user == null) {
     setState(() {
       _showLoader = false;
     });
     
     await showAlertDialog(
       context: context,
       title: 'Error',
       message: 'Hubo un problema al obtener el usuario de Google, por favor intenta más tarde.',
       actions: <AlertDialogAction>[
         AlertDialogAction(key: null, label: 'Aceptar'),
       ]
     );
     return;
   }
   
   Map<String, dynamic> request = {
     'email': user.email,
     'id': user.id,
     'loginType': 1,
     'fullName': user.displayName,
     'photoUrl': user.photoUrl
   };

   await _socialLogin(request);
 }

 Future _socialLogin(Map<String, dynamic> request) async {
   var url = Uri.parse('${Constans.apiUrl}/api/Account/SocialLogin');
   var bodyRequest = jsonEncode(request);
   var response = await http.post(
     url,
     headers: {
       'content-type' : 'application/json',
       'accept' : 'application/json',
      },
      body: bodyRequest,
   );

   print(response.body);
   
   setState(() {
     _showLoader = false;
   });
   
   if(response.statusCode >= 400) {
     await showAlertDialog(
       context: context,
       title: 'Error', 
       message: 'El usuario ya inció sesión previamente por email o por otra red social.',
       actions: <AlertDialogAction>[
         AlertDialogAction(key: null, label: 'Aceptar'),
       ]
     ); 
     return;
   }
   
   var body = response.body;
   
   var decodedJson = jsonDecode(body);
   var token = Token.fromJson(decodedJson);
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(
       builder: (context) => RecordsScreens(token: token)
     )
   );
 }

}