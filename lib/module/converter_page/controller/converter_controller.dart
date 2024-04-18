
import 'package:currency_converter_app/global/utils/global.dart';
class ConverterController {
  final ApiHelper apiHelper = ApiHelper();
  late double result = 0.0;
  late Future<List<SymbolName>> symbolsListFuture;
  SymbolName? selectedFromSymbol;
  SymbolName? selectedToSymbol;
  bool isTimeOut = false;
  final RegExp numericRegex =
      RegExp(r'^\d*\.?\d*$'); // Regular expression for integers and doubles

  Future<bool?> convertCurrencyFunction(
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

    if (numericRegex.hasMatch(result.toString())) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initializeSymbolsList() async {
    symbolsListFuture = apiHelper.getSymbolsList();
  }
}
