import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class PLC_Config extends ChangeNotifier {
  // SerialPort port;
  // String selectedPort = 'COM4';
  // String output = '';
  // bool isConnected = false;
  // late SerialPortReader reader;
  // StreamSubscription? subscription;

  // void connect() {
  //   port = SerialPort(selectedPort);

  //   if (!port.openReadWrite()) {
  //     output = '⚠️ Failed to open port $selectedPort';
  //     return;
  //   }
  // }

  // final config = port.config;
  // config.baudRate = 115200;
  // config.bits = 8;
  // config.parity = SerialPortParity.even;
  // config.stopBits = 1;
  // config.setFlowControl(SerialPortFlowControl.none);
  // port.config = config;

  // void sendCommandfromProvider(String command) {
  //   port = SerialPort(selectedPort);

  //   if (port.isOpen) {
  //     //  return "com port err";

  //     port.write(Utf8Encoder().convert(command));
  //     output += '\n➡️ Sent: ${command.trim()}-->';
  //     //  String respons = output.split('-->').last.trim();
  //     // return respons;
  //   }
  // }

  notifyListeners();
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
