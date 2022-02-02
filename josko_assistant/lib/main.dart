import 'package:flutter/material.dart';
import 'package:josko_assistant/findDevicesScreen.dart';

void main()
{
  runApp(SIARS());
}

class SIARS extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      initialRoute: '/',
      routes: 
      {
        '/' : (context) => FindDevicesScreen(),
      },
    );
  }
}