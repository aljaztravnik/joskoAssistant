import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:josko_assistant/addTask.dart';
import 'package:josko_assistant/deleteTask.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicScreen extends StatefulWidget {
  const MicScreen({Key key, @required this.device, @required this.userID, @required this.ipAddr}) : super(key: key);
  final BluetoothDevice device;
  final String userID;
  final String ipAddr;
  @override
  _MicScreenState createState() => _MicScreenState();
}

class _MicScreenState extends State<MicScreen> {
  static const String COMMAND_SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String COMMAND_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  BluetoothCharacteristic commandCharacteristic;
  stt.SpeechToText _speech;
  bool _isListening = false;
  bool error, sending, success;
  bool loadTasks = false;
  String msg;
  //String phpurl = "http://192.168.1.7/joskoAssistant_restApi/main.php";
  String _text = '';
  List<String> taskTypes;
  // TASK MORE MET: pinNum, typeID ------ kasneje še lokacijo ali številko naprave
  List<Map<String, int>> tasks = List<Map<String, int>>.empty(growable: true);
  List<String> iconNames = ['toggle-switch-off', 'clock-outline', 'music-note'];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    connectToDevice();
    requestTaskTypes();
  }

  Future<void> requestTaskTypes() async {
    String phpUrl = "http://" + widget.ipAddr + "/joskoAssistant_restApi/main.php";
    var res = await http.post(Uri.parse(phpUrl), body: {
      "gettasktypes": "ja",
    });

    if (res.statusCode == 200)
    {
      // SENDING SUCCESS
      print(res.body);
      var data = json.decode(res.body);
      if(data["error"]) print("ERROR: ${data["message"]}");
      else
      {
        // REQUEST SUCCESS
        print("TASK TYPES!!!!!!!!!!!!!");
        taskTypes = data["message"].split(",");
        for(int i = 0; i < taskTypes.length; i++)
          print("${taskTypes[i]}");

        requestTaskList(); // ob uspehu in napolnjenem taskTypes arrayu, se kliče requestTaskList
      }
    }
  }

  Future<void> requestTaskList() async {
    String phpUrl = "http://" + widget.ipAddr + "/joskoAssistant_restApi/main.php";
    var res = await http.post(Uri.parse(phpUrl), body: {
      "gettasklist": "ja",
      "userid": widget.userID,
    });

    if (res.statusCode == 200)
    {
      // SENDING SUCCESS
      var data = json.decode(res.body);
      if(data["error"]) print("ERROR: ${data["message"]}");
      else
      {
        // REQUEST SUCCESS
        List<String> splitTasks = data["message"].split(",");

        for (String t in splitTasks) {
          List<String> splitT = t.split(":");
          Map<String, int> task = {"taskID": int.parse(splitT[0]), "pinNum": int.parse(splitT[1]), "typeID": int.parse(splitT[2]) - 1};
          tasks.add(task);
        }
        print("TASKS LENGTH: ${tasks.length}");
        setState(() {
          loadTasks = true;
        });
      }
    }
  }

  updateTaskList()
  {
    tasks.clear();
    requestTaskList();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == COMMAND_SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == COMMAND_CHARACTERISTIC_UUID)
            commandCharacteristic = characteristic;
        });
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Ali ste prepričani?'),
              content: Text('Prekini povezavo?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('Ne')),
                new FlatButton(
                    onPressed: () {
                      disconnectFromDevice();
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

  sendCommand() async 
  {
    List<String> turnOnOffUkazi = ["lights", "computer", "song", "music"]; // keywordi, ki imajo lahko on/off, start/stop itd.
    List<String> otherUkazi = ["time"];                                    // keywordi, ki samo nekaj naredijo
    // te stringi so pol custom (dodajajo se ob dodajanju taska in se posodabljajo tut na esp32)

    String ukaz = "";
    int i = 0;
    String onOff = "0";

    if (_text.contains("turn on") || _text.contains("start") || _text.contains("resume")) onOff = "1";
    else if (_text.contains("turn off") || _text.contains("stop") || _text.contains("pause")) onOff = "0";

    for (final u in turnOnOffUkazi)
    {
      if (_text.contains(u))
      {
        ukaz = i.toString() + " " + onOff;
        if(_text.contains("pin")) // preveri na katerem pinu more funkcija neki nardit
        {
          List<String> splitText = _text.split(" ");
          bool added = false;
          for(int j = 0; j < splitText.length; j++)
            if((splitText[j] == "pin" || splitText[j] == "in" || splitText[j] == "pink") && (j+1 < splitText.length))
            {
              ukaz += " " + splitText[j+1]; // doda št. pina v ukaz
              added = true;
              break;
            }
          if(!added) ukaz += " 99"; 
        }
        else ukaz += " 99"; // če besede "pin" ni v ukazu
        i++;
        break;
      }
      i++;
    }

    for (final u in otherUkazi)
    {
      if (_text.contains(u))
      {
        ukaz = i.toString() + " 1 99";
        i++;
        break;
      }
      i++;
    }

    await commandCharacteristic.write(utf8.encode(ukaz));
    //await commandCharacteristic.write(utf8.encode(_text));
  }

  void _listen() async {
    if (!_isListening)
    {
      bool available = await _speech.initialize(
        onStatus: (val) => print("onStatus: $val"),
        onError: (val) => print("onError: $val"),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    }
    else
    {
      print("RECEIVED TEXT: $_text");
      setState(() {
        _isListening = false;
      });
      _speech.stop();
      await sendCommand();
      //_text = '';
    }
  }

  List<Widget> taskWidgets()
  {
    List<Widget> kids = [];

    kids.add(SizedBox(height: 20.0));
    kids.add(
      Row
      (
        children: <Widget>
        [
          RaisedButton
          (
            elevation: 5.0,
            onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask(userID: widget.userID, types: taskTypes, ipAddr: widget.ipAddr,))).then((context) {updateTaskList();});
            },
            //padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            //color: Colors.white,
            child: Icon(MdiIcons.fromString('plus-box'), color: Colors.white),
          ),
          RaisedButton
          (
            elevation: 5.0,
            onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteTask(userID: widget.userID, types: taskTypes, taskList: tasks, ipAddr: widget.ipAddr,))).then((context) {updateTaskList();});
            },
            //padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            //color: Colors.white,
            child: Icon(MdiIcons.fromString('minus-box'), color: Colors.white),
          ),
        ]
      )
    );

    for(int i = 0; i < tasks.length; i++)
    {
      kids.add(SizedBox(height: 20.0));
      kids.add(
        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>
          [
            SizedBox(width: 5.0,),
            Text(taskTypes[tasks[i]["typeID"]] + ((tasks[i]["typeID"] == 0) ? " ${tasks[i]["pinNum"].toString()}" : ""), style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            // KLE BO IME OD FUNKCIJE
            RaisedButton
            (
              elevation: 5.0,
              onPressed: ()
              {                            
              
              },
              //padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //color: Colors.white,
              child: Icon(MdiIcons.fromString(iconNames[tasks[i]["typeID"]]), color: Colors.white),
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
                      _listen();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    child: Icon(
                        _isListening
                            ? MdiIcons.microphoneOff
                            : MdiIcons.microphone,
                        color: Colors.black),
                  ),
                  RaisedButton(
                    elevation: 5.0,
                    onPressed: () {
                      setState(() {
                        _text = '';
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    child: Text(
                      "Počisti",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'OpenSans',
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ]
              ),
              Padding(padding: EdgeInsets.only(bottom: 15)),
              Text(
                "Govor: $_text",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                    fontSize: 25.0,
                    fontWeight: FontWeight.normal
                ),
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
