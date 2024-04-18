import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/global/model/currency_symbol.dart';

class ConverterController {
  final ApiHelper apiHelper = ApiHelper();
  late double result = 0.0;
  late Future<List<SymbolName>> symbolsListFuture;
  SymbolName? selectedFromSymbol;
  SymbolName? selectedToSymbol;
   bool isTimeOut = false;

  Future<void> convertCurrencyFunction(
      {required String from,
      required String to,
      required String amount,
      required Function setState}) async {
    double parsedAmount = double.parse(amount);
    var output =
        await apiHelper.convertCurrencyUsingExgRate(from, to, parsedAmount);
    setState(() {
      result = output;
    });
    print(output);
  }

  Future<void> initializeSymbolsList() async {
    symbolsListFuture = apiHelper.getSymbolsList();
  }
}
