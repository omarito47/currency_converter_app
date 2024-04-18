import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter_app/global/api/api_converter.dart';
import 'package:currency_converter_app/global/connectivity_handler/controller/connectivity_controller.dart';
import 'package:currency_converter_app/global/model/currency_symbol.dart';
import 'package:currency_converter_app/global/utils/constant.dart';
import 'package:currency_converter_app/module/converter_page/controller/converter_controller.dart';
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
  final ConverterController _converterController =
      ConverterController(); // Create an instance of ConverterController

  // Create an instance of connectivitySubscription
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Create an instance of ConnectivityService
  late ConnectivityService _connectivityService;

  late TextEditingController amountController;
  final RefreshController _refreshControllerAPIon =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerAPIoff =
      RefreshController(initialRefresh: false);
  
  // Functions

  void _onRefreshAPIoff() async {
    setState(() {
      _converterController.isTimeOut = false;
    });
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _converterController.symbolsListFuture = ApiHelper().getSymbolsList();
    if (mounted) setState(() {});

    _refreshControllerAPIon.refreshCompleted();
    _refreshControllerAPIoff.refreshCompleted();
  }

  void _onLoadingAPIoff() async {
    // monitor network fetch
    await Future.delayed(Duration(seconds: 1));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {
      _converterController.symbolsListFuture = ApiHelper().getSymbolsList();
    });
    if (mounted) setState(() {});
    _refreshControllerAPIon.loadComplete();
    _refreshControllerAPIoff.loadComplete();
  }

  void _onRefreshAPIon() async {
    setState(() {
      _converterController.isTimeOut = false;
    });
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _converterController.convertCurrencyFunction(
      from: _converterController.selectedFromSymbol!.code,
      to: _converterController.selectedToSymbol!.code,
      amount: amountController.text,
      setState: setState,
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
      _converterController.convertCurrencyFunction(
        from: _converterController.selectedFromSymbol!.code,
        to: _converterController.selectedToSymbol!.code,
        amount: amountController.text,
        setState: setState,
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
    _converterController.symbolsListFuture = ApiHelper().getSymbolsList();
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
        title: Text(ConstantHelper.currencyAppTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SymbolName>>(
        future: _converterController.symbolsListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final symbolsList = snapshot.data!;
            if (_converterController.selectedFromSymbol == null &&
                symbolsList.isNotEmpty) {
              _converterController.selectedFromSymbol = symbolsList[0];
            }
            if (_converterController.selectedToSymbol == null &&
                symbolsList.length > 1) {
              _converterController.selectedToSymbol = symbolsList[1];
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ConstantHelper.enterAmount,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: ConstantHelper.sizex24 * 2),
                      Column(
                        children: [
                          Text(ConstantHelper.convertCurrency),
                          DropdownButton<SymbolName>(
                            //dropdownColor: Colors.grey,
                            value: _converterController.selectedFromSymbol,
                            hint: Text(ConstantHelper.selectFromSymbol),
                            onChanged: (newValue) {
                              setState(() {
                                _converterController.selectedFromSymbol =
                                    newValue;
                              });
                            },
                            underline: Container(
                              height: ConstantHelper.sizex02,
                              color: Colors.red,
                            ),
                            items: symbolsList.map((symbol) {
                              return DropdownMenuItem<SymbolName>(
                                value: symbol,
                                child: Text(
                                  '${symbol.code} - ${symbol.name}',
                                  style: TextStyle(
                                    color: _converterController
                                                .selectedFromSymbol ==
                                            symbol
                                        ? Colors.black
                                        : Colors.red, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            margin: EdgeInsets.all(ConstantHelper.sizex10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: IconButton(
                              onPressed: () {
                                late SymbolName symbol;
                                setState(() {
                                  symbol =
                                      _converterController.selectedFromSymbol!;
                                  _converterController.selectedFromSymbol =
                                      _converterController.selectedToSymbol!;
                                  _converterController.selectedToSymbol =
                                      symbol;
                                  _converterController.convertCurrencyFunction(
                                    from: _converterController
                                        .selectedFromSymbol!.code,
                                    to: _converterController
                                        .selectedToSymbol!.code,
                                    amount: amountController.text,
                                    setState: setState,
                                  );
                                });
                              },
                              icon: const Icon(Icons.swap_vert_outlined),
                              color: Colors
                                  .white, // Optionally, you can specify the icon color
                            ),
                          ),
                          Text(ConstantHelper.toCurrencyTitle),
                          DropdownButton<SymbolName>(
                            //dropdownColor: Colors.blue,
                            value: _converterController.selectedToSymbol,
                            hint: Text(ConstantHelper.selectToSymbol),
                            onChanged: (newValue) {
                              setState(() {
                                _converterController.selectedToSymbol =
                                    newValue;
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
                                    color: _converterController
                                                .selectedToSymbol ==
                                            symbol
                                        ? Colors.black
                                        : Colors.blue, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: ConstantHelper.sizex24 * 2),
                      Text(
                          "Result = ${_converterController.result} ${_converterController.selectedToSymbol!.code}",
                          style: TextStyle(fontSize: ConstantHelper.sizex20)),
                      SizedBox(height: ConstantHelper.sizex24 + 6),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.trim().isEmpty ||
                              amountController.text
                                  .contains(RegExp(r'[A-Z,a-z]')) ||
                              amountController.text.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ||
                              !RegExp(r'^\d+$')
                                  .hasMatch(amountController.text)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(ConstantHelper.warningTitle),
                                content:
                                    Text(ConstantHelper.warningNonValidAmount),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(ConstantHelper.ok),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            _converterController.convertCurrencyFunction(
                                from: _converterController
                                    .selectedFromSymbol!.code,
                                to: _converterController.selectedToSymbol!.code,
                                amount: amountController.text,
                                setState: setState);
                          }
                        },
                        child: Text(ConstantHelper.convertTitle),
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
                      padding: EdgeInsets.all(ConstantHelper.sizex08),
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
