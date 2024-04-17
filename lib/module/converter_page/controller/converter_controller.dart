import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/global/model/currency_symbol.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConverterController {
  // variabes
  late Future<List<SymbolName>> symbolsListFuture;
  SymbolName? selectedFromSymbol;
  SymbolName? selectedToSymbol;
  final amountController = TextEditingController();
  final ApiHelper apiHelper = ApiHelper();
  double result = 0.0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isTimeOut = false;

  // Logic
  Future<List<SymbolName>> getSymbolsList() async {
    final symbolsList = await apiHelper.getSymbolsList();
    return symbolsList;
  }

  void convertCurrencyFunction(
      {required String from,
      required String to,
      required String amount,
      required Function setState}) async {
    try {
      double parsedAmount = double.parse(amount);
      var output = await apiHelper.convertCurrency(from, to, parsedAmount);

      setState(() {
        result = output.result;
      });
      print(output.result);
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    amountController.dispose();
  }
}
