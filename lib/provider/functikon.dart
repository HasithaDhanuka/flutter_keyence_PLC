import 'package:flutter/material.dart';

class PLC_Data extends ChangeNotifier {
  String relay = "";
  String comVal = "";
  List<String> receivedData = [];

  void changeRelayVal(String update_relay) {
    relay = update_relay;
    //  print("update output data ::->${relay}");
    notifyListeners();
  }

  void listenComPort(String comVal) {
    receivedData.add("\t$comVal\n".trim());
    receivedData.add(comVal.trim());

    print("relay data is :: $receivedData");
    notifyListeners();
  }

  String get update_relay => relay;
}
