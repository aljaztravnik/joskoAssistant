import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'dart:convert';
import 'findDevicesScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_blue/flutter_blue.dart';

class LoginScreen extends StatefulWidget
{
  const LoginScreen({Key key}) : super(key: key);
  @override 
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  int hereAuthenticated = 0;
  bool hasInternet = false;
  String phpurl = "http://192.168.1.2/joskoAssistant_restApi/main.php";

  checkInternetConnectivity() async
  {
    try 
    {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
      {
        print('WE HAVE INTERNET');
        hasInternet = true;
      }
    } on SocketException catch (_) 
    {
      print("WE DON'T HAVE INTERNET");
      hasInternet = false;
    }
  }

  @override
  void initState()
  {
    super.initState();
    print("SEM V INIT STATE");
    checkInternetConnectivity();
  }

  @override
  void dispose() {
    print("SEM V DISPOSE");
    super.dispose();
  }

  Future<void> sendLoginRequest() async {
    var res = await http.post(Uri.parse(phpurl), body: {
      "username": usernameTextController.text,
      "password": passwordTextController.text,
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
        setState(() {
          hereAuthenticated = 1;
        });
      }
    }
  }

  Widget _buildEmailTF() {
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
              hintText: 'Uporabniško ime',
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
              hintText: 'Geslo',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () {

        },
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Pozabil sem geslo',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()
        {
          sendLoginRequest();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'PRIJAVA',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  List<Widget> getLoginScreen()
  {
      List<Widget> kids = [];
      if(hasInternet)
      {
        if(hereAuthenticated == 0)
        {
          kids.add(new Container
          (
            height: double.infinity,
            width: double.infinity,
            color: Colors.blue,
          ));
        }

        if(hereAuthenticated == 0)
        {
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
                  Text('Josko Assistant',style: TextStyle(color: Colors.white,fontFamily: 'OpenSans',fontSize: 30.0,fontWeight: FontWeight.bold,),),
                  SizedBox(height: 30.0),
                  _buildEmailTF(),
                  SizedBox(height: 30.0,),
                  _buildPasswordTF(),
                  _buildForgotPasswordBtn(),
                  _buildLoginBtn(),
                ],
              ),
            ),
          ));
        }
        else if(hereAuthenticated == 1)
        {
          /*return(
            StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) 
              {
                final state = snapshot.data;
                return FindDevicesScreen();
              }
            ));
          return FindDevicesScreen();*/
          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => FindDevicesScreen()));
        }
    }
    else
    {
      kids.add
      (
        Container
        (
          color: Colors.blue,
          child: Center
          (
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>
              [
                Text("Preverite internetno povezavo in ponovno zaženite aplikacijo.", style: TextStyle(color: Colors.white,fontFamily: 'OpenSans',fontSize: 20.0,fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
              ]
            )
          ),
        )
      );
    }
    
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
            children: getLoginScreen(),
          ),
        ),
      )
    );
  }
}