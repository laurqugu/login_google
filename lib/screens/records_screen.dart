import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:login_google/components/loader_component.dart';
import 'package:login_google/helpers/api_helper.dart';
import 'package:login_google/models/record.dart';
import 'package:login_google/models/response.dart';
import 'package:login_google/models/token.dart';
import 'package:login_google/screens/record_screen.dart';

class RecordsScreens extends StatefulWidget {
  final Token token;

  RecordsScreens({required this.token});

  @override
  _RecordsScreensState createState() => _RecordsScreensState();
}

class _RecordsScreensState extends State<RecordsScreens> {
  late Record _records;
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuestas de Satisfacción'),
        backgroundColor: Colors.red[200],
      ),
      body: Center(
        child: _showLoader ? LoaderComponent(text: 'Cargando...') : _getListView(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getRecords() async{
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
        message: 'Verifica tu conexión a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Response response = await ApiHelper.getRecords(widget.token);
    print(response);

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
      _records = response.result;
    });
  }


  Widget _getListView() {
    return Container(
      child: ListView(
        children: [
          Row(
            children: [
              Text(
                _records.id.toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text(
                _records.email,
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text(
                _records.theBest,
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text(
                _records.theWorst,
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text(
                _records.remarks,
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text(
                _records.qualification.toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
        ],
      ), 
    );
  }

  void _goEdit(Record record) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => RecordScreen(
          token: widget.token,
          record: record
        )
      )
    );
    if (result == 'yes') {
      _getRecords();
    }
  }

  void _goAdd() async{
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => RecordScreen(
          token: widget.token, 
          record: Record(id: 0, email: '', theBest: '', theWorst: '', remarks: '', qualification: 0),
        )
      )
    );
    if(result == 'yes'){
      _getRecords();
    }
  }
}