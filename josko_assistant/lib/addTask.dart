import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddTask extends StatefulWidget {
  const AddTask({Key key}) : super(key: key);
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddTask> {
  bool error, sending, success;
  bool loadTasks = false;
  String msg;
  String phpurl = "http://192.168.1.2/joskoAssistant_restApi/main.php";
  List<String> taskTypes;
  // TASK MORE MET: pinNum, typeID ------ kasneje še lokacijo ali številko naprave
  List<Map<String, int>> tasks = List<Map<String, int>>.empty(growable: true);
  List<String> iconNames = ['toggle-switch-off', 'clock-outline', 'music-note'];

  @override
  void initState() {
    super.initState();
    requestTaskTypes();
  }

  Future<void> requestTaskTypes() async {
    var res = await http.post(Uri.parse(phpurl), body: {
      "gettasktypes": "ja",
    });

    if (res.statusCode == 200)
    {
      // SENDING SUCCESS
      print(res.body);
      var data = json.decode(res.body);
      if(data["error"]) print("REQUEST ERROR: ${data["error"]}");
      else
      {
        // REQUEST SUCCESS
        print("TASK TYPES!!!!!!!!!!!!!");
        taskTypes = data["message"].split(",");
        for(int i = 0; i < taskTypes.length; i++)
          print("${taskTypes[i]}");

        // OD KLE SE GRE NAPREJ
      }
    }
  }


  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Cancel adding tasks?'),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
        ),
      ),
    );
  }

  @override
  void dispose() => super.dispose();
}
