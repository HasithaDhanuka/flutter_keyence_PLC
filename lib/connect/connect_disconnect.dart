// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'dart:async';
// import 'dart:convert';

// class SerialService {
//   late SerialPort _port;
//   late SerialPortReader _reader;
//   StreamSubscription? _subscription;

//   final String portName;
//   final int baudRate;
//   final void Function(String) onData;
//   bool isConnected = false;

//   SerialService({
//     required this.portName,
//     this.baudRate = 115200,
//     required this.onData,
//   });

//   bool connect() {
//     _port = SerialPort(portName);

//     if (!_port.openReadWrite()) {
//       onData('⚠️ Failed to open port $portName');
//       return false;
//     }

//     final config = _port.config;
//     config.baudRate = baudRate;
//     config.bits = 8;
//     config.parity = SerialPortParity.even;
//     config.stopBits = 1;
//     config.setFlowControl(SerialPortFlowControl.none);
//     _port.config = config;

//     _reader = SerialPortReader(_port);
//     _subscription = _reader.stream.listen((data) {
//       onData(utf8.decode(data, allowMalformed: true));
//     });

//     isConnected = true;
//     onData('✅ Connected to $portName\n');
//     return true;
//   }

//   void disconnect() {
//     _subscription?.cancel();
//     if (_port.isOpen) _port.close();
//     isConnected = false;
//     onData('\n🔌 Disconnected from $portName');
//   }





//   void send(String command) {
//     if (_port.isOpen) {
//       _port.write(utf8.encode(command));
//       onData('\n➡️ Sent: ${command.trim()}');
//     }
//   }
// }
