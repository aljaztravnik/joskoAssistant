import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget
{
  const RegistrationScreen({Key key}) : super(key: key);
  @override 
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
{
  TextEditingController ipTextController = TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    print("SEM V INIT STATE");
  }

  @override
  void dispose() {
    print("SEM V DISPOSE");
    super.dispose();
  }

  Future<void> sendRegistrationRequest() async {
    String phpUrl = "http://192.168.1.7/joskoAssistant_restApi/main.php";
    var res = await http.post(Uri.parse(phpUrl), body: {
      "registration": "ja",
      "username": usernameTextController.text,
      "password": passwordTextController.text,
    });

    if (res.statusCode == 200)
    {
      // SENDING SUCCESS
      print(res.body);
      var data = json.decode(res.body);
      if(data["error"]) print("REQUEST ERROR: ${data["error"]}");
      else{
        print("Registracija: ${data["message"]}");
        Navigator.of(context).pop(true);
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

  Widget _buildRegistrationBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()
        {
          sendRegistrationRequest();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'REGISTRACIJA',
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
            Text('Registracija',style: TextStyle(color: Colors.white,fontFamily: 'OpenSans',fontSize: 30.0,fontWeight: FontWeight.bold,),),
            SizedBox(height: 30.0),
            _buildEmailTF(),
            SizedBox(height: 30.0,),
            _buildPasswordTF(),
            _buildRegistrationBtn(),
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
