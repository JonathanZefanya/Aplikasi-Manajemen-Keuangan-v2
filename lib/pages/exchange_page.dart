import 'package:dio/dio.dart';
import 'package:tangan/components/error_message.dart';
import 'package:tangan/components/info_dialog.dart';
import 'package:tangan/components/last_update.dart';
import 'package:tangan/components/swap_button.dart';
import 'package:tangan/models/exchange_rates.dart';
import 'package:tangan/pages/select_currency.dart';
import 'package:tangan/utils/constant.dart';
import 'package:flag/flag.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_money_formatter/flutter_money_formatter.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:tangan/models/currency.dart';
import 'package:intl/intl.dart';
import 'setting_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ExchangePage extends StatefulWidget {
  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final Dio dio = Dio();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  bool isLoading = true;
  late TextEditingController _controller;
  Currency origin = Currency(
      text: "USD - United States Dollar",
      key: "us",
      value: "USD",
      flag: "us",
      symbol: "\$");
  Currency destination = Currency(
      text: "IDR - Indonesian Rupiah",
      key: "id",
      value: "IDR",
      flag: "id",
      symbol: "Rp");

  int current = 1;

  late Future<ExchangeRates> future;
  bool isBase = true;
  double resultConvert = 0;

  //ads
  // BannerAd _bannerAd;

  // BannerAd createBannerAd() {
  //   return BannerAd(
  //     adUnitId: 'ca-app-pub-9619934169053673/5625207799',
  //     size: AdSize.banner,
  //     targetingInfo: MobileAdTargetingInfo(
  //       keywords: <String>['finance', 'money'],
  //       contentUrl: 'https://exchangeratesapi.io',
  //       childDirected: false,
  //     ),
  //     listener: (MobileAdEvent event) {
  //       print("BannerAd event $event");
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    // FirebaseAdMob.instance
    //     .initialize(appId: 'ca-app-pub-9619934169053673~5402966071');
    // _bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
    _controller = TextEditingController(text: '1');
    getData();
  }

  getData() {
    setState(() {
      var url = "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_NtT2hzNdOgxNj3PVdPLFb2sHsYommRq57yZYuCtz";
      future = dio
          .get(url, options: Options(headers: {
            "apikey": "fca_live_NtT2hzNdOgxNj3PVdPLFb2sHsYommRq57yZYuCtz"
          }))
          .then((resp) => ExchangeRates.fromJson(resp.data));

          print(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: Container(
          color: primary,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back_ios_new_sharp, color: base),
                ),
                Text(
                  (lang == 0) ? "Kurs Mata Uang" : 'Convert Currency',
                  style: GoogleFonts.inder(
                    fontSize: 23,
                    color: base,
                  ),
                ),
              ],  
            ),
          ),
        ),
        ),
        backgroundColor: isDark ? background : base,
        body: Padding(
          padding: const EdgeInsets.only(bottom: 54),
          child: FutureBuilder<ExchangeRates>(
              future: future, 
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return showData(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorMessage(
                      msg: snapshot.error.toString(),
                      onPressed: () {
                        getData();
                      },
                    ),
                  ));
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ));
                }
              }),     
        ));
  }

  Widget showData(ExchangeRates data) {
    convertAction();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    color: Color(0xfff6f6f6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            height: 35,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4))),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                child: Flag.fromString(
                                    '${origin.flag}', width: 30, height: 40)),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectCurrency(
                                                currency: origin,
                                              )));

                                  if (result != null) {
                                    setState(() {
                                      origin = result;
                                      isBase = true;
                                    });
                                    await getData();
                                    convertAction();
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${origin.text.split("-")[0]}',
                                          style: kCountryTextStyle,
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xff3b3f47),
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${origin.text.split("-")[1].trim()}',
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 4, right: 16, top: 12, bottom: 8),
                                  border: InputBorder.none,
                                ),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w300),
                                keyboardType: TextInputType.number,
                                controller: _controller,
                                onChanged: (value) {
                                  convertAction();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xfff6f6f6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 35,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    child: Flag.fromString(
                                        '${destination.flag}', width: 30, height: 40)),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                "=",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 32,
                                    color: Colors.black38),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectCurrency(
                                                currency: destination,
                                              )));

                                  if (result != null) {
                                    setState(() {
                                      destination = result;
                                    });
                                    convertAction();
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${destination.text.split("-")[0]}',
                                          style: TextStyle(
                                              color: Color(0xff3b3f47),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xff3b3f47),
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${destination.text.split("-")[1].trim()}',
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, left: 4),
                                child: Text(
                                  "${oCcy.format(resultConvert)}",
                                  // FlutterMoneyFormatter(
                                  //         amount: resultConvert,
                                  //         settings: MoneyFormatterSettings(
                                  //             thousandSeparator: ".",
                                  //             decimalSeparator: ","))
                                  //     .output
                                  //     .nonSymbol,
                                  style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 140,
                right: 32,
                child: SwapButton(
                  onTap: () {
                    Currency temp = origin;
                    setState(() {
                      origin = destination;
                      destination = temp;
                      isBase = !isBase;
                    });
                    convertAction();
                  },
                ),
              ),
            ],
          ),
          LastUpdate(date: data.date)
        ],
      ),
    );
  }

  void convertAction() {
    future.then((v) {
      setState(() {
        try {
          if (_controller.text.isNotEmpty) {
            if (int.parse(_controller.text) > 0) {
              if (isBase) {
                resultConvert =
                    (v.rates[destination.value]! * int.parse(_controller.text));
              } else {
                resultConvert =
                    int.parse(_controller.text) / v.rates[origin.value]!;
              }
            } else {
              resultConvert = 0;
            }
          } else {
            resultConvert = 0;
          }
        } catch (e) {
          print("errors ${e.toString()}");
          resultConvert = 0;
        }
      });
    });
  }

  Future<void> showInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return InfoDialog();
      },
    );
  }

  @override
  void dispose() {
    //_bannerAd?.dispose();
    super.dispose();
  }
  
}

class ConnectivityCheck extends StatefulWidget {
  @override
  _ConnectivityCheckState createState() => _ConnectivityCheckState();
}

class _ConnectivityCheckState extends State<ConnectivityCheck> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    } as void Function(List<ConnectivityResult> event)?);
  }

  Future<void> _checkConnectivity() async {
    ConnectivityResult result;
    try {
      result = (await _connectivity.checkConnectivity()) as ConnectivityResult;
    } catch (e) {
      result = ConnectivityResult.none;
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _connectivityResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connectivity Check'),
      ),
      body: Center(
        child: _connectivityResult == ConnectivityResult.none
            ? Text(
                'Koneksi internet tidak ada',
                style: TextStyle(fontSize: 24, color: Colors.red),
              )
            : Text(
                'Koneksi internet tersedia',
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
      ),
    );
  }
}