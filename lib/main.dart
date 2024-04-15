import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Currency Converter'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [MyButton(), MySecondButton()],
        ),
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  const MyButton({super.key});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  final ApiHelper apiHelper = ApiHelper();

  void convertCurrencyFunction() async {
    try {
      var result = await apiHelper.convertCurrency('TND', 'EUR', 100);
      print(result.result);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: convertCurrencyFunction,
      child: Text('Convert Currency'),
    );
  }
}

class MySecondButton extends StatefulWidget {
  const MySecondButton({super.key});

  @override
  State<MySecondButton> createState() => MySecondButtonState();
}

class MySecondButtonState extends State<MySecondButton> {
  final ApiHelper apiHelper = ApiHelper();

  void getCurrencySymbole() async {
    try {
      var result = await apiHelper.getSymbols();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: getCurrencySymbole,
      child: Text('get symbols name'),
    );
  }
}
