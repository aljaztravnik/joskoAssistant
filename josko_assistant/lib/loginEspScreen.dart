import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'micScreen.dart';

class LoginEspScreen extends StatefulWidget
{
  const LoginEspScreen({Key key, @required this.device, @required this.userID, @required this.ipAddr}) : super(key: key);
  final BluetoothDevice device;
  final String userID;
  final String ipAddr;
  @override 
  _LoginEspScreenState createState() => _LoginEspScreenState();
}

class _LoginEspScreenState extends State<LoginEspScreen>
{
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  String mode;

  @override
  void initState()
  {
    super.initState();
    print("SEM V INIT STATE");
    if(widget.userID == "1") mode = "admin";
    else if(widget.userID == "2" || widget.userID == "3") mode = "user";
    else mode = "fail"; 
  }

  @override
  void dispose() {
    print("SEM V DISPOSE");
    super.dispose();
  }

  Widget _buildWiFiTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: usernameTextController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'WiFi ime',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordTextController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'WiFi geslo',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()
        {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MicScreen(device: widget.device, userID: widget.userID, ipAddr: widget.ipAddr,)));
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Pošlji podatke',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildOKbutton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()
        {
          if(mode != "fail") Navigator.of(context).push(MaterialPageRoute(builder: (context) => MicScreen(device: widget.device, userID: widget.userID, ipAddr: widget.ipAddr,)));
          else Navigator.of(context).pop(true);
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Vredu',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  List<Widget> getRegistrationScreen()
  {
    List<Widget> kids = [];
    kids.add(new Container
    (
      height: double.infinity,
      width: double.infinity,
      color: Colors.blue,
    ));
    kids.add(new Container
    (
      height: double.infinity,
      child: SingleChildScrollView
      (
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric
        (
          horizontal: 40.0,
          vertical: 120.0,
        ),
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Text((mode == "admin") ? 'Vpisani kot admin' : (mode == "user") ? 'Vpisani kot user' : 'Neuspel vpis' ,style: TextStyle(color: Colors.white,fontFamily: 'OpenSans',fontSize: 30.0,fontWeight: FontWeight.bold,),),
            //SizedBox(height: 30.0),
            //_buildWiFiTF(),
            //SizedBox(height: 30.0,),
            //_buildPasswordTF(),
            //
            _buildOKbutton(),
          ],
        ),
      ),
    ));
    
    return kids;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: getRegistrationScreen(),
          ),
        ),
      )
    );
  }
}