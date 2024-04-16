import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/global/model/currency_symbol.dart';
import 'package:flutter/material.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({Key? key}) : super(key: key);

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late Future<List<SymbolName>> _symbolsListFuture;
  SymbolName? _selectedFromSymbol;
  SymbolName? _selectedToSymbol;
  final ApiHelper apiHelper = ApiHelper();
  late double result = 0.0;
  late TextEditingController amountController;
  void convertCurrencyFunction(String from, String to, String amount) async {
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

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    _symbolsListFuture = ApiHelper().getSymbolsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter App"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SymbolName>>(
        future: _symbolsListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final symbolsList = snapshot.data!;
            if (_selectedFromSymbol == null && symbolsList.isNotEmpty) {
              _selectedFromSymbol = symbolsList[0];
            }
            if (_selectedToSymbol == null && symbolsList.length > 1) {
              _selectedToSymbol = symbolsList[1];
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Amount to convert'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter the amount to convert',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 50),
                        Column(
                          children: [
                            const Text('Convert from currency'),
                            DropdownButton<SymbolName>(
                              //dropdownColor: Colors.grey,
                              value: _selectedFromSymbol,
                              hint: const Text('Select from symbol'),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedFromSymbol = newValue;
                                });
                              },
                              underline: Container(
                                height: 2,
                                color: Colors.red,
                              ),
                              items: symbolsList.map((symbol) {
                                return DropdownMenuItem<SymbolName>(
                                  value: symbol,
                                  child: Text(
                                    '${symbol.code} - ${symbol.name}',
                                    style: TextStyle(
                                      color: _selectedFromSymbol == symbol
                                          ? Colors.white
                                          : Colors.red, // Change the color here
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  late SymbolName symbol;
                                  setState(() {
                                    symbol = _selectedFromSymbol!;
                                    _selectedFromSymbol = _selectedToSymbol!;
                                    _selectedToSymbol = symbol;
                                    convertCurrencyFunction(
                                        _selectedFromSymbol!.code,
                                        _selectedToSymbol!.code,
                                        amountController.text);
                                  });
                                },
                                icon: const Icon(Icons.swap_vert_outlined),
                                color: Colors
                                    .black, // Optionally, you can specify the icon color
                              ),
                            ),
                            const Text('To currency'),
                            DropdownButton<SymbolName>(
                              //dropdownColor: Colors.blue,
                              value: _selectedToSymbol,
                              hint: const Text('Select to symbol'),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedToSymbol = newValue;
                                });
                              },
                              underline: Container(
                                height: 2,
                                color: Colors.blue,
                              ),
                              items: symbolsList.map((symbol) {
                                return DropdownMenuItem<SymbolName>(
                                  value: symbol,
                                  child: Text(
                                    '${symbol.code} - ${symbol.name}',
                                    style: TextStyle(
                                      color: _selectedToSymbol == symbol
                                          ? Colors.white
                                          : Colors
                                              .blue, // Change the color here
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Text("Result = $result ${_selectedToSymbol!.code}",
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (amountController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Warning'),
                                  content: const Text(
                                      'Please enter the amount to convert it.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              convertCurrencyFunction(
                                _selectedFromSymbol!.code,
                                _selectedToSymbol!.code,
                                amountController.text,
                              );
                            }
                          },
                          child: const Text("Convert"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load symbols'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
      child: const Text('Convert Currency'),
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
      var result = await apiHelper.getSymbolsList();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: getCurrencySymbole,
      child: const Text('get symbols name'),
    );
  }
}
