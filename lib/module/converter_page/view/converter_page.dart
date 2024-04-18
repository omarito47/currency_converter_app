import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:currency_converter_app/global/utils/global.dart';

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
    Timer.periodic(const Duration(seconds: 2) * 2, (_) {
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
                backgroundColor: ConstantHelper.white,
                color: ConstantHelper.blue,
              ),
              controller: _refreshControllerAPIon,
              onRefresh: _onRefreshAPIon,
              onLoading: _onLoadingAPIon,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                          height:
                              ConstantHelper.sizex24 * ConstantHelper.sizex04),
                      Text(ConstantHelper.amountToConvert),
                      SizedBox(height: ConstantHelper.sizex10),
                      TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              _converterController.numericRegex),
                        ],
                        controller: amountController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ConstantHelper.enterAmount,
                        ),
                      ),
                      SizedBox(height: ConstantHelper.sizex24 * 2),
                      Column(
                        children: [
                          Text(ConstantHelper.convertCurrency),
                          DropdownButton<SymbolName>(
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
                              color: ConstantHelper.red,
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
                                        ? ConstantHelper.black
                                        : ConstantHelper
                                            .red, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            margin: EdgeInsets.all(ConstantHelper.sizex10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ConstantHelper.blue,
                            ),
                            child: IconButton(
                                onPressed: () {
                                  late SymbolName symbol;
                                  setState(() {
                                    symbol = _converterController
                                        .selectedFromSymbol!;
                                    _converterController.selectedFromSymbol =
                                        _converterController.selectedToSymbol!;
                                    _converterController.selectedToSymbol =
                                        symbol;
                                    _converterController
                                        .convertCurrencyFunction(
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
                                color: ConstantHelper.white),
                          ),
                          Text(ConstantHelper.toCurrencyTitle),
                          DropdownButton<SymbolName>(
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
                              color: ConstantHelper.blue,
                            ),
                            items: symbolsList.map((symbol) {
                              return DropdownMenuItem<SymbolName>(
                                value: symbol,
                                child: Text(
                                  '${symbol.code} - ${symbol.name}',
                                  style: TextStyle(
                                    color:
                                        _converterController.selectedToSymbol ==
                                                symbol
                                            ? ConstantHelper.black
                                            : ConstantHelper
                                                .black, // Change the color here
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(
                          height:
                              ConstantHelper.sizex24 * ConstantHelper.sizex02),
                      Text(
                          "Result = ${_converterController.result} ${_converterController.selectedToSymbol!.code}",
                          style: TextStyle(fontSize: ConstantHelper.sizex20)),
                      SizedBox(
                          height:
                              ConstantHelper.sizex24 + ConstantHelper.sizex06),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_converterController.numericRegex
                                  .hasMatch(amountController.text) ||
                              amountController.text == "." ||
                              amountController.text.trim().isEmpty) {
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
                            final success = await _converterController
                                .convertCurrencyFunction(
                              from:
                                  _converterController.selectedFromSymbol!.code,
                              to: _converterController.selectedToSymbol!.code,
                              amount: amountController.text,
                              setState: setState,
                            );

                            if (!success!) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(ConstantHelper.whoopsText),
                                  content: Text(ConstantHelper.errorApi),
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
                            }
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
                backgroundColor: ConstantHelper.white,
                color: ConstantHelper.blue,
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
                            fontWeight: FontWeight.bold,
                            color: ConstantHelper.black),
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
