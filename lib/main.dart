import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLC Serial Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SerialPage(),
    );
  }
}

class SerialPage extends StatefulWidget {
  @override
  _SerialPageState createState() => _SerialPageState();
}

class _SerialPageState extends State<SerialPage> {
  late SerialPort port;
  String selectedPort = 'COM4';
  String output = '';
  bool isConnected = false;
  late SerialPortReader reader;
  StreamSubscription? subscription;

  void connect() {
    port = SerialPort(selectedPort);

    if (!port.openReadWrite()) {
      setState(() {
        output = '⚠️ Failed to open port $selectedPort';
      });
      return;
    }

    final config = port.config;
    config.baudRate = 115200;
    config.bits = 8;
    config.parity = SerialPortParity.even;
    config.stopBits = 1;
    config.setFlowControl(SerialPortFlowControl.none);
    port.config = config;

    reader = SerialPortReader(port);
    subscription = reader.stream.listen((data) {
      setState(() {
        output += utf8.decode(data, allowMalformed: true);
      });
    });

    setState(() {
      isConnected = true;
      output = '✅ Connected to $selectedPort\n';
      sendCommand('CR\r');
    });
  }

  void disconnect() {
    subscription?.cancel();
    if (port.isOpen) port.close();
    setState(() {
      isConnected = false;
      output += '\n🔌 Disconnected from $selectedPort';
    });
  }

  void sendCommand(String command) {
    if (!port.isOpen) return;
    port.write(Utf8Encoder().convert(command));
    setState(() {
      output += '\n➡️ Sent: ${command.trim()}';
    });
  }

  @override
  void dispose() {
    if (port.isOpen) port.close();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availablePorts = SerialPort.availablePorts;

    return Scaffold(
      appBar: AppBar(title: const Text('PLC Serial Monitor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedPort,
              onChanged: (value) {
                if (value != null) setState(() => selectedPort = value);
              },
              items: availablePorts
                  .map((port) => DropdownMenuItem(
                        child: Text(port),
                        value: port,
                      ))
                  .toList(),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isConnected ? null : connect,
                  child: Text('Connect'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isConnected ? disconnect : null,
                  child: Text('Disconnect'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: Container(
                height: 300,
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    output,
                    style: TextStyle(
                        color: Colors.greenAccent, fontFamily: 'Courier'),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            if (isConnected)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => sendCommand('WR MR35002 1\r'),
                    child: Text('INIT PLC'),
                  ),
                ],
              ),
            SizedBox(height: 10),
            //#############    TRAY FEEDER  ON/OFF     ##################################################
            Row(
              children: [
                // ElevatedButton(
                //   onPressed: () => sendCommand('CR\r'),
                //   child: Text('Send CR'),
                // ),
                // SizedBox(width: 10),
                // ElevatedButton(
                //   onPressed: () => sendCommand('WR DM0.U 9\r'),
                //   child: Text('Send RD DM0'),
                // ),

                ElevatedButton(
                  onPressed: () => sendCommand('WR MR35802 1\r'),
                  child: Text('Tray Feeder ON'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => sendCommand('WR MR35802 0\r'),
                  child: Text('Tray Feeder OFF'),
                ),
              ],
            ),
            SizedBox(height: 10),
//#############    DEBUG MOde     ##################################################
            Row(
              children: [
                // ElevatedButton(
                //   onPressed: () => sendCommand('CR\r'),
                //   child: Text('Send CR'),
                // ),
                // SizedBox(width: 10),
                // ElevatedButton(
                //   onPressed: () => sendCommand('WR DM0.U 9\r'),
                //   child: Text('Send RD DM0'),
                // ),

                ElevatedButton(
                  onPressed: () => sendCommand('WR MR35410 1\r'),
                  child: Text('DEBUG MODE ON'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => sendCommand('WR MR35410 0\r'),
                  child: Text('DEBUG MODE OFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
