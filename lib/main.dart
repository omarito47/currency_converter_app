import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/module/converter_page/view/converter_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
            useMaterial3: true),
        home:const ConverterPage());
  }
}
