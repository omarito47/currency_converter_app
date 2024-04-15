class ConversionResult {
  final String date;
  final double rate;
  final int timestamp;
  final int amount;
  final String fromCurrency;
  final String toCurrency;
  final double result;
  final bool success;

  ConversionResult({
    required this.date,
    required this.rate,
    required this.timestamp,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.result,
    required this.success,
  });

  factory ConversionResult.fromJson(Map<String, dynamic> json) {
    return ConversionResult(
      date: json['date'],
      rate: json['info']['rate'],
      timestamp: json['info']['timestamp'],
      amount: json['query']['amount'],
      fromCurrency: json['query']['from'],
      toCurrency: json['query']['to'],
      result: json['result'],
      success: json['success'],
    );
  }
}