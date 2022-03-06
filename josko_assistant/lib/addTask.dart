import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddTask extends StatefulWidget {
  const AddTask({Key key, @required this.userID, this.types}) : super(key: key);
  final String userID;
  final List<String> types;
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddTask> {
  bool error, sending, success;
  bool loadTasks = false;
  String msg;
  String phpurl = "http://192.168.1.7/joskoAssistant_restApi/main.php";
  String dropdownvalue;
  TextEditingController pinTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dropdownvalue = widget.types[0];
  }

  Future<void> addNewTask() async {
    print("PIN ŠTEVILKA: ${pinTextController.text}");
    print("TYPE ID: ${(widget.types.indexWhere((element) => element == dropdownvalue)).toString()}");
    print("USER ID: ${widget.userID}");

    var res = await http.post(Uri.parse(phpurl), body: {
      "addtask": "ja",
      "pinnum": pinTextController.text,
      "typeid": (widget.types.indexWhere((element) => element == dropdownvalue) + 1).toString(),
      "userid": widget.userID,
    });

    if (res.statusCode == 200)
    {
      // SENDING SUCCESS
      print(res.body);
      var data = json.decode(res.body);
      if(data["error"]) print("ERROR: ${data["error"]}");
      else{
        print("SUCCESS: ${data["message"]}");
        Navigator.of(context).pop(true);
      }
    }
  }


  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Ali ste prepričani?'),
              content: Text('Prekliči dodajanje opravil?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes')),
              ],
            ) ??
            false);
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  List<Widget> addTaskWidgets()
  {
    List<Widget> kids = [];

    kids.add(SizedBox(height: 70.0));
    kids.add(Text("Dodajanje funkcije", style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,));
    kids.add(SizedBox(height: 40.0));
    kids.add(Text("Tip funkcije", style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,));
    kids.add(SizedBox(height: 30.0));
    kids.add(DropdownButton<String>(
      value: dropdownvalue,
      icon: const Icon(Icons.keyboard_arrow_down),    
      items: widget.types.map((String x) {
      return DropdownMenuItem<String>(
        value: x,
        child: Text(x),
      );}).toList(),
      onChanged: (String newValue) { 
        setState(() {
          dropdownvalue = newValue;
        });
      },
    ));
    kids.add(
      Container(
        alignment: Alignment.centerLeft,
        decoration: kBoxDecorationStyle,
        height: 60.0,
        child: TextField(
          controller: pinTextController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OpenSans',
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14.0),
            prefixIcon: Icon(MdiIcons.fromString("flash"),color: Colors.white,),
            hintText: 'Številka pina',
            hintStyle: kHintTextStyle,
          ),
        ),
      ),
    );

    return kids;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: <Widget>
            [
              Container
              (
                decoration: kBoxDecorationStyle,
                //width: MediaQuery.of(context).size.width - 10,
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: addTaskWidgets()
                )
              ),
              Padding(padding: EdgeInsets.only(bottom: 15)),
              Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>
                [
                  RaisedButton(
                    elevation: 5.0,
                    onPressed: () {
                      addNewTask();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    child: Text(
                      "Dodaj",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'OpenSans',
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  RaisedButton(
                    elevation: 5.0,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    child: Text(
                      "Prekliči",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'OpenSans',
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                ]
              ),
            ]
          ),
        ),
      ),
    );
  }

  @override
  void dispose() => super.dispose();
}
