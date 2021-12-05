import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import 'package:login_google/components/loader_component.dart';
import 'package:login_google/helpers/constans.dart';
import 'package:login_google/models/token.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email = '';
  String _dontLike = '';
  String _like = '';
  String _comments = '';
  int _rating = 0;
  
  String _emailError = '';
  String _dontLikeError = '';
  String _likeError = '';
  String _ratingError = '';
  String _commentsError = '';

  bool _emailShowError = false;
  bool _dontLikeShowError = false;
  bool _likeShowError = false;
  bool _ratingShowError = false;
  bool _commentsShowError = false;
  bool _showLoader = false;

  @override
    void initState() {
    super.initState();
    _getRecords(widget.token);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Calificación'),
        backgroundColor: Colors.red[200],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10,),
                _showEmail(),
                SizedBox(height: 10,),
                _showLike(),
                SizedBox(height: 10,),
                _showDontLike(),
                SizedBox(height: 10,),
                _showComments(),
                SizedBox(height: 10,),
                _showRating(),
                SizedBox(height: 20,),
                _showButton(),
              ],
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Cargando...') : Container(),
        ],
      ),
      
    );
  }
  
  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Ingrese su correo electrónico',
          errorText: _emailShowError ? _emailError : null,
          suffixIcon: Icon(Icons.email),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showLike() {
   return Container(
    padding: EdgeInsets.all(10),
    child: TextField(
      decoration: InputDecoration(
        labelText: 'Ingresa lo que mas te gustó del curso',
        errorText: _likeShowError ? _likeError : null,
        suffixIcon: Icon(Icons.thumb_up_alt),
      ),
      onChanged: (value) {
        _like = value;
      },
    ),
   );
 }

  Widget _showDontLike() {
   return Container(
    padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Ingresa lo que menos te gustó del curso',
          errorText: _dontLikeShowError ? _dontLikeError : null,
          suffixIcon: Icon(Icons.thumb_down_alt),
        ),
        onChanged: (value) {
          _dontLike = value;
        },
      ),
   );
 }

  Widget _showComments() {   
  return Container(
    padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Comentarios',
          errorText: _commentsShowError ? _commentsError : null,
          suffixIcon: Icon(Icons.comment),
        ),
        onChanged: (value) {
          _comments = value;
        },
      ),
   );}

  Widget _showRating() {
  return RatingBar.builder(
    initialRating: 0,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 15.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: (rating) {
      _rating = rating.toInt();
    },
  );
 }
 
  Widget _showButton() {
   return Container(
     margin: EdgeInsets.only(left: 10, right: 10),
     child: Row(
       children: <Widget>[
         Expanded(
           child: ElevatedButton(
             child: Text('Enviar'),
             onPressed: () => _save(widget.token),
           )
         )
       ],
     )
   );
  }

  void _save(Token token) async{
    if (!_validateFields()) {
        return;
    }
    
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
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'email': _email,
      'qualification': _rating,
      'theBest': _like,
      'theWorst': _dontLike,
      'remarks': _comments,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Finals');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}'
      },
      body: jsonEncode(request),
    );
    print(request);
    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      print(
          "error al consumir el metodo POST" + response.statusCode.toString());
      return;
    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    print(decodedJson);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
 
  }

  bool _validateFields(){
   bool isValid = true;

   if(_email.isEmpty){
     isValid = false;
     _emailShowError = true;
     _emailError = "Debes ingresar un correo";
   } else if (!EmailValidator.validate(_email)){
     isValid = false;
     _emailShowError = true;
     _emailError = "Debes ingresar un correo";
   } else if (!RegExp("\b*@correo\.itm\.edu\.co\$").hasMatch(_email)){
     isValid = false;
     _emailShowError = true;
     _emailError = "Debes ingresar un correo con dominio del ITM";
   }
   
   if(_like.isEmpty){
     isValid = false;
     _likeShowError = true;
     _likeError = "Por favor escribir lo que mas te gustó del curso.";
   }

   if(_dontLike.isEmpty){
     isValid = false;
     _dontLikeShowError = true;
     _dontLikeError = "Por favor escribir lo que menos te gustó del curso.";
   }

   if(_comments.isEmpty){
     isValid = false;
     _commentsShowError = true;
     _commentsError = "Por favor escribir algún comentario.";
   }

   if(_rating == 0){
     isValid = false;
     _ratingShowError = true;
     _ratingError = "Debes ingresar tu calificación.";
   }

   setState(() {});
   
   return isValid;
 }
 
  void _getRecords(Token token) {}

  bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }
}