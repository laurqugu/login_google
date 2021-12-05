import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
   var googleSignIn = GoogleSignIn();
   await googleSignIn.signOut();
   var user = await googleSignIn.signIn();
   print(user);
 }
}