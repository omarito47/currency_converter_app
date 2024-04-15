class Currency {
  final String code;
  final String name;

  Currency(this.code, this.name);

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(json['code'], json['name']);
  }
}