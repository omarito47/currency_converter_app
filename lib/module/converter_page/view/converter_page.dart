import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/global/connectivity_handler/controller/connectivity_controller.dart';
import 'package:currency_converter_app/global/model/currency_symbol.dart';
import 'package:currency_converter_app/global/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:lottie/lottie.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({Key? key}) : super(key: key);

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  // variables
  // Create an instance of connectivitySubscription
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Create an instance of ConnectivityService
  late ConnectivityService _connectivityService;
  late Future<List<SymbolName>> _symbolsListFuture;
  SymbolName? _selectedFromSymbol;
  SymbolName? _selectedToSymbol;
  final ApiHelper apiHelper = ApiHelper();
  late double result = 0.0;
  late TextEditingController amountController;
  RefreshController _refreshControllerAPIon =
      RefreshController(initialRefresh: false);
  RefreshController _refreshControllerAPIoff =
      RefreshController(initialRefresh: false);
  bool _isTimeOut = false;
  // Functions
  void convertCurrencyFunction(
      {required String from,
      required String to,
      required String amount}) async {

      double parsedAmount = double.parse(amount);
      var output =
          await apiHelper.convertCurrencySecondWay(from, to, parsedAmount);
      setState(() {
        result = output;
      });
      print(output);

  }

  void _onRefreshAPIoff() async {
    setState(() {
      _isTimeOut = false;
    });
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _symbolsListFuture = ApiHelper().getSymbolsList();
    if (mounted) setState(() {});

    _refreshControllerAPIon.refreshCompleted();
    _refreshControllerAPIoff.refreshCompleted();
  }

  void _onLoadingAPIoff() async {
    // monitor network fetch
    await Future.delayed(Duration(seconds: 1));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {
      _symbolsListFuture = ApiHelper().getSymbolsList();
    });
    if (mounted) setState(() {});
    _refreshControllerAPIon.loadComplete();
    _refreshControllerAPIoff.loadComplete();
  }

  void _onRefreshAPIon() async {
    setState(() {
      _isTimeOut = false;
    });
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    convertCurrencyFunction(
      from: _selectedFromSymbol!.code,
      to: _selectedToSymbol!.code,
      amount: amountController.text,
    );
    if (mounted) setState(() {});

    _refreshControllerAPIon.refreshCompleted();
    _refreshControllerAPIoff.refreshCompleted();
  }

  void _onLoadingAPIon() async {
    // monitor network fetch
    await Future.delayed(Duration(seconds: 1));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {
      convertCurrencyFunction(
        from: _selectedFromSymbol!.code,
        to: _selectedToSymbol!.code,
        amount: amountController.text,
      );
    });
    if (mounted) setState(() {});
    _refreshControllerAPIon.loadComplete();
    _refreshControllerAPIoff.loadComplete();
  }

  @override
  void initState() {
    // Instantiate the ConnectivityService class and pass the context to it
    _connectivityService = ConnectivityService(context: context);

    // Check for initial connectivity status
    _connectivityService.checkConnectivity();

    // Start checking for connectivity every 5 seconds
    Timer.periodic(const Duration(milliseconds: 2400) * 2, (_) {
      _connectivityService.checkConnectivity();
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_connectivityService.updateConnectivity);
    super.initState();
    amountController = TextEditingController();
    _symbolsListFuture = ApiHelper().getSymbolsList();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();

    // TODO: implement dispose
    super.dispose();
    amountController.dispose();
    _refreshControllerAPIon.dispose();
    _refreshControllerAPIoff.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(ConstantHelper.currencyAppTitle),
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

            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                backgroundColor: Colors.white,
                color: Colors.blue,
              ),
              controller: _refreshControllerAPIon,
              onRefresh: _onRefreshAPIon,
              onLoading: _onLoadingAPIon,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: ConstantHelper.sizex24 * 4),
                       Text(ConstantHelper.amountToConvert),
                      SizedBox(height: ConstantHelper.sizex10),
                      TextField(
                        controller: amountController,
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ConstantHelper.enterAmount,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                       SizedBox(height: ConstantHelper.sizex24*2),
                      Column(
                        children: [
                           Text(ConstantHelper.convertCurrency),
                          DropdownButton<SymbolName>(
                            //dropdownColor: Colors.grey,
                            value: _selectedFromSymbol,
                            hint:  Text(ConstantHelper.selectFromSymbol),
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
                                        ? Colors.black
                                        : Colors.red, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            margin:  EdgeInsets.all(ConstantHelper.sizex10),
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
                                      from: _selectedFromSymbol!.code,
                                      to: _selectedToSymbol!.code,
                                      amount: amountController.text);
                                });
                              },
                              icon: const Icon(Icons.swap_vert_outlined),
                              color: Colors
                                  .black, // Optionally, you can specify the icon color
                            ),
                          ),
                           Text(ConstantHelper.toCurrencyTitle),
                          DropdownButton<SymbolName>(
                            //dropdownColor: Colors.blue,
                            value: _selectedToSymbol,
                            hint:  Text(ConstantHelper.selectToSymbol),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedToSymbol = newValue;
                              });
                            },
                            underline: Container(
                              height: ConstantHelper.sizex02,
                              color: Colors.blue,
                            ),
                            items: symbolsList.map((symbol) {
                              return DropdownMenuItem<SymbolName>(
                                value: symbol,
                                child: Text(
                                  '${symbol.code} - ${symbol.name}',
                                  style: TextStyle(
                                    color: _selectedToSymbol == symbol
                                        ? Colors.black
                                        : Colors.blue, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                       SizedBox(height: ConstantHelper.sizex24*2),
                      Text("Result = $result ${_selectedToSymbol!.code}",
                          style:  TextStyle(fontSize: ConstantHelper.sizex20)),
                       SizedBox(height: ConstantHelper.sizex24 +6 ),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.trim().isEmpty ||
                              amountController.text
                                  .contains(RegExp(r'[A-Z,a-z]')) ||
                              amountController.text.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:  Text(ConstantHelper.warningTitle),
                                content:  Text(
                                    ConstantHelper.warningNonValidAmount),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child:  Text(ConstantHelper.ok),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            convertCurrencyFunction(
                              from: _selectedFromSymbol!.code,
                              to: _selectedToSymbol!.code,
                              amount: amountController.text,
                            );
                          }
                        },
                        child:  Text(ConstantHelper.convertTitle),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                backgroundColor: Colors.white,
                color: Colors.blue,
              ),
              controller: _refreshControllerAPIoff,
              onRefresh: _onRefreshAPIoff,
              onLoading: _onLoadingAPIoff,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .25),
                child: Column(
                  children: [
                    Center(
                      child: Lottie.asset('assets/json/animation_11.json',
                          width: MediaQuery.of(context).size.width * .6),
                    ),
                    Padding(
                      padding:  EdgeInsets.all(ConstantHelper.sizex08),
                      child: Text(
                        ConstantHelper.errorApi,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
