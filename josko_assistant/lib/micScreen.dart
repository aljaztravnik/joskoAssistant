import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicScreen extends StatefulWidget {
  const MicScreen({Key key, @required this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _MicScreenState createState() => _MicScreenState();
}

class _MicScreenState extends State<MicScreen> {
  static const String COMMAND_SERVICE_UUID =
      "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String COMMAND_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  BluetoothCharacteristic commandCharacteristic;
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    /*new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });*/

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
              title: Text('Are you sure?'),
              content: Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No')),
                new FlatButton(
                    onPressed: () {
                      disconnectFromDevice();
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

  sendCommand() async {
    List<String> turnOnOffUkazi = ["lights", "computer", "song", "music"];
    List<String> otherUkazi = ["time"];

    String ukaz = "";
    int i = 0;
    int onOff = 0;

    if (_text.contains("turn on") || _text.contains("start") || _text.contains("resume")) onOff = 1;
    else if (_text.contains("turn off") || _text.contains("stop") || _text.contains("pause")) onOff = 0;

    for (final u in turnOnOffUkazi) {
      if (_text.contains(u)) {
        ukaz = i.toString() + " " + onOff.toString();
        i++;
        break;
      }
      i++;
    }

    for (final u in otherUkazi) {
      if (_text.contains(u)) {
        ukaz = i.toString() + " 1";
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
                  children: <Widget>
                  [
                    SizedBox(height: 20.0),
                    // VSI ROW ELEMENTI MORJO BIT GENERIRANI V FOR LOOPU 
                    Row
                    (
                      children: <Widget>
                      [
                        SizedBox(width: 5.0,),
                        Text("LUČ DNEVNA", style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
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
                          child: Icon(MdiIcons.fromString('toggle-switch-off'), color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row
                    (
                      children: <Widget>
                      [
                        SizedBox(width: 5.0,),
                        Text("TIME", style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
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
                          child: Icon(MdiIcons.fromString('clock-outline'), color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ]
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
                      "CLEAR",
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
                "Command: $_text",
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
