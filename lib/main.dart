import 'package:conv2/provider/functikon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:convert';
import 'dart:async';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PLC_Data()),
      ],
      builder: (context, child) => const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  bool isDebugMode = false;

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

/*#################       READ DATA       ########################################
################################################################################*/
    reader = SerialPortReader(port);
    subscription = reader.stream.listen((data) {
      output += utf8.decode(data, allowMalformed: true);
      String comportData = utf8.decode(data, allowMalformed: true);
      context.read<PLC_Data>().changeRelayVal(output);
      context.read<PLC_Data>().listenComPort(comportData);
      //  print("get com port ::$output");

      // setState(() {
      //   output += utf8.decode(data, allowMalformed: true);
      //   String data1 = utf8.decode(data, allowMalformed: true);
      //   print("out is :: $data1");
      // });
    });

/*#################       Connect PLC        ####################################
################################################################################*/
    setState(() {
      sendCommand('CR\r');
      sendCommand('RD MR35410\r');
      isConnected = true;
      output = '✅ Connected to $selectedPort\n';
    });
  }

/*#################       Disconnect PLC     ####################################
################################################################################*/
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
    output += '\n➡️ Sent: ${command.trim()} -->';
    context.read<PLC_Data>().changeRelayVal(command);
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   sendCommand('CR\r');
  // }

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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => sendCommand(' MR35002 1\r'),
                  child: Text('Update relay'),
                ),
              ],
            ),
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
/*#################       OUTPUT   M O N I T O R    ##############################
################################################################################*/
                  child: Text(
                    context.watch<PLC_Data>().relay,
                    // output,
                    style: const TextStyle(
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
                !isDebugMode
                    ? ElevatedButton(
                        onPressed: () => sendCommand('WR MR35410 1\r'),
                        child: Text('DEBUG MODE ON'),
                      )
                    : const SizedBox(width: 10),
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
