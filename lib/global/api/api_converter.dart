import 'dart:convert';

import 'package:currency_converter_app/global/model/conversion_result_model.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String _apiKey = 'NgvuYj14C5YVQF7WItqdryUmeXFxfJdS';
  final String _baseUrl = 'https://api.apilayer.com/exchangerates_data';

  Future<String> getSymbols() async {
    var url = Uri.parse('$_baseUrl/symbols');
    var headers = {'apikey': _apiKey};

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<ConversionResult> convertCurrency(String from, String to, double amount) async {
    var url = Uri.parse('$_baseUrl/convert?to=$to&from=$from&amount=$amount');
    var headers = {'apikey': _apiKey};

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return ConversionResult.fromJson(jsonDecode(response.body));
   
    } else {
      throw Exception('Failed to load data');
    }
  }
}
