import 'package:conv2/provider/function.dart';
import 'package:conv2/screen/popup_daialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        ChangeNotifierProvider(create: (_) => PLC_Relay_Update()),
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
  late SerialPortReader reader;
  StreamSubscription? subscription;

  bool isConnected = false;
  // bool ismachineStart = false;
  // bool isDebugMode = false;
  // bool isTrayFeederOn = false;

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
      // print("output is:: $output");
      String comportData = utf8.decode(data, allowMalformed: true);
      context.read<PLC_Data>().changeRelayVal(output);
      context.read<PLC_Data>().listenComPort(comportData);
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

  String sendCommand(String command) {
    if (!port.isOpen) {
      return "com port err";
    }

    port.write(Utf8Encoder().convert(command));
    output += '\n➡️ Sent: ${command.trim()}-->';
    context.read<PLC_Data>().changeRelayVal(command);
    String respons = output.split('-->').last.trim();
    return respons;
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
        child: Consumer<PLC_Relay_Update>(
          builder: (context, value, child) => Column(
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
                    child: const Text('Connect'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isConnected ? disconnect : null,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isConnected)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        openDialog(context: context, port: port);
                      },
                      //  sendCommand('RD MR35009\r'),
                      child: const Text('Manual Mode'),
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
              const SizedBox(height: 10),

              if (isConnected)
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(209, 7, 143, 228)),
                      onPressed: () {
                        sendCommand('WR MR35002 1\r');
                        // bool ismachineStart = false;
                        // bool isConnected = false;
                        // bool isDebugMode = false;
                        // bool isTrayFeederOn = false;

                        context.read<PLC_Relay_Update>().ismachineStart = false;
                        // context.read<PLC_Relay_Update>().isConnected = false;
                        context.read<PLC_Relay_Update>().isDebugMode = false;
                        context.read<PLC_Relay_Update>().isTrayFeederOn = false;
                      },
                      child: Text('INIT PLC'),
                    ),
                    !value.ismachineStart

                        //!ismachineStart
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(209, 36, 244, 21)),
                              onPressed: () {
                                sendCommand('WR MR35009 1\r');
                                value.ismachineStart = true;
                              },
                              child: Text('検査開始'),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(245, 235, 4, 58)),
                              onPressed: () {
                                sendCommand('WR MR35009 0\r');
                                value.ismachineStart = false;
                              },
                              child: Text('検査停止'),
                            ),
                          ),
                  ],
                ),
              const SizedBox(height: 10),
              //#############    TRAY FEEDER  ON/OFF     ##################################################
              if (isConnected)
                Row(
                  children: [
                    // ElevatedButton(
                    //   onPressed: () => sendCommand('CR\r'),
                    //   child: Text('Send CR'),
                    // ),
                    // const SizedBox(width: 10),
                    // ElevatedButton(
                    //   onPressed: () => sendCommand('WR DM0.U 9\r'),
                    //   child: Text('Send RD DM0'),
                    // ),
                    !value.isTrayFeederOn
                        ? ElevatedButton(
                            onPressed: () {
                              sendCommand('WR MR35802 1\r');
                              value.isTrayFeederOn = true;
                            },
                            child: Text('Tray Feeder ON'),
                          )
                        : // const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {
                              sendCommand('WR MR35802 0\r');
                              value.isTrayFeederOn = false;
                            },
                            child: Text('Tray Feeder OFF'),
                          ),
                  ],
                ),
              const SizedBox(height: 30),
              //#############    DEBUG MOde     ##################################################
              if (isConnected)
                Row(
                  children: [
                    !value.isDebugMode
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(209, 228, 70, 7)),
                            onPressed: () {
                              sendCommand('WR MR35410 1\r');
                              value.isDebugMode = true;
                            },
                            child: const Text(
                              'DEBUG MODE ON',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : //const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {
                              sendCommand('WR MR35410 0\r');
                              value.isDebugMode = false;
                            },
                            child: Text('DEBUG MODE OFF'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(224, 239, 220, 11)),
                          ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
