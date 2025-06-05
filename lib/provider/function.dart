import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class PLC_Relay_Update extends ChangeNotifier {
  //bool isConnected = false;
  bool ismachineStart = false;
  bool isDebugMode = false;
  bool isTrayFeederOn = false;

  void relay_update() {
    //  isConnected;
    ismachineStart;
    isDebugMode;
    isTrayFeederOn;
    notifyListeners();
  }
}

class PLC_Data extends ChangeNotifier {
  String relay = "";
  String responseComVal = "##";
  List<String> receivedData = [];

  void changeRelayVal(String update_relay) {
    relay = update_relay;

    String? respons = relay.split('-->').last.trim();
    print(" command respons :$respons");
    notifyListeners();
  }

  Future<void> listenComPort(String comVal) async {
    receivedData.clear();
    receivedData.add("\t$comVal\n".trim());
    receivedData.add(comVal.trim());
    responseComVal = comVal;
    await Future.delayed(const Duration(milliseconds: 500));

    //  print("response :: $responseComVal");
    //  print("relay data is :: $receivedData");
    //  print(receivedData.length);

    notifyListeners();
  }

  String get update_relay => relay;
}
