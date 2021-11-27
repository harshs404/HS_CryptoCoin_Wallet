// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_coin/slider_widget.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: Colors.blue),
        ),
      ),
      home: const MyHomePage(title: 'HSCOIN'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  int myAmount = 0;
  final myAddress = "0x348B39351d17c93ccbc680495553e7Cf42B3c10e";
  String txHash = "";
  var myData;
  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/52c48f2c645d4cf58782d0532ad62934",
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x460eB370df312776BcCCA88D72cB4Ee9F297f96A";
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "HSCoin"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(String TargetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(TargetAddress);
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    data = true;
    setState(() {});
    print("Refreshed");
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "36c2b151a0b8256b3acb8c803e078c2ff6d9098e00fb6780bc88623ef8d93217");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract, function: ethFunction, parameters: args),
      chainId: null,
      fetchChainIdFromNetworkId: true,
    );
    return result;
  }

  Future<String> sendCoin() async {
    var bigAmout = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmout]);
    print("Deposited");
    setState(() {});
    txHash = response;
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmout = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmout]);
    print("Withdrawn");
    setState(() {});
    txHash = response;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          color: Colors.grey[300],
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                color: Colors.blue[600],
              ),
              Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment(0.0, -0.75),
                      child: Text(
                        '\$HSCOIN',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .25,
                        right: 20.0,
                        left: 20.0),
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 9,
                            spreadRadius: 7,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          data
                              ? Center(
                                  child: Text(
                                    '\$$myData',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Center(child: CircularProgressIndicator()),
                          SizedBox(height: 30),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: SliderWidget(
                  min: 0,
                  max: 100,
                  finalVal: (double value) {
                    myAmount = (value * 100).round();
                    print(myAmount);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .45),
                      child: ElevatedButton.icon(
                        onPressed: () => getBalance(myAddress),
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          minimumSize: Size(70, 50),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .45),
                      child: ElevatedButton.icon(
                        onPressed: () => sendCoin(),
                        icon: Icon(Icons.call_made_outlined),
                        label: Text('Deposit'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          elevation: 10,
                          minimumSize: Size(70, 50),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .45),
                      child: ElevatedButton.icon(
                        onPressed: () => withdrawCoin(),
                        icon: Icon(Icons.call_received_outlined),
                        label: Text('Withdraw'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[400],
                          elevation: 10,
                          minimumSize: Size(70, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (txHash != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .75,
                    left: 30,
                    right: 30,
                  ),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * .90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 9,
                          spreadRadius: 7,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(txHash),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
