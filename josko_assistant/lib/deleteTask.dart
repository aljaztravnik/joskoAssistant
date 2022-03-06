import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

class DeleteTask extends StatefulWidget {
  const DeleteTask({Key key, @required this.userID, @required this.types, @required this.taskList}) : super(key: key);
  final String userID;
  final List<String> types;
  final List<Map<String, int>> taskList;
  @override
  _DeleteTaskState createState() => _DeleteTaskState();
}

class _DeleteTaskState extends State<DeleteTask> {
  bool error, sending, success;
  bool loadTasks = false;
  String msg;
  String phpurl = "http://192.168.1.7/joskoAssistant_restApi/main.php";
  List<Map<String, int>> taskList2 = List<Map<String, int>>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    taskList2 = widget.taskList;
  }

  Future<void> deleteSelectedTask(int i) async {
    var res = await http.post(Uri.parse(phpurl), body: {
      "deletetask": (widget.taskList[i]["taskID"]).toString(),
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
        widget.taskList.removeAt(i);
        if(widget.taskList.length == 0) Navigator.of(context).pop(true);
        setState(() {
          loadTasks = true;
        });
      }
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Ali ste prepričani?'),
              content: Text('Prekliči odstranjevanje opravil?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('Ne')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Ja')),
              ],
            ) ??
            false);
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  List<Widget> taskWidgets()
  {
    List<Widget> kids = [];

    kids.add(SizedBox(height: 20.0));
    for(int i = 0; i < widget.taskList.length; i++)
    {
      kids.add(SizedBox(height: 20.0));
      kids.add(
        Row
        (
          children: <Widget>
          [
            SizedBox(width: 5.0,),
            Text(widget.types[widget.taskList[i]["typeID"]] + ((widget.taskList[i]["typeID"] == 0) ? " ${widget.taskList[i]["pinNum"].toString()}" : ""), style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            // KLE BO IME OD FUNKCIJE
            RaisedButton
            (
              elevation: 5.0,
              onPressed: ()
              {                            
                deleteSelectedTask(i);
              },
              //padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //color: Colors.white,
              child: Icon(MdiIcons.fromString("delete"), color: Colors.white),
            ),
          ],
        )
      );
    }
    
    return kids;    
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
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
                  children: taskWidgets()
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
                      Navigator.of(context).pop(true);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    child: Text(
                      "Nazaj",
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
