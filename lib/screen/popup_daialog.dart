import 'dart:convert';
import 'dart:math';

import 'package:conv2/provider/functikon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

Future openDialog({required BuildContext context, required port}) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
          title: const Text("Manual Mode"),
          content: SingleChildScrollView(
            padding: EdgeInsets.all(0.8),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Text("上流"),
                Row(
                  children: [
                    output_button(
                        port: port,
                        command: "WR MR35501 1\r",
                        buttonName: "上流スライダーを開く"),
                    output_button(
                        port: port,
                        command: "WR MR35500 1\r",
                        buttonName: "上流スライダーを閉める"),
                    output_button(
                        port: port,
                        command: "WR MR35502 1\r",
                        buttonName: "上流ガイド開く"),
                    output_button(
                        port: port,
                        command: "WR MR35503 1\r",
                        buttonName: "上流ガイド閉める"),
                  ],
                ),
                Row(
                  children: [
                    output_button(
                        port: port,
                        command: "WR MR35504 1\r",
                        buttonName: "上流入口扉開く"),
                    output_button(
                        port: port,
                        command: "WR MR35505 1\r",
                        buttonName: "上流入口扉閉める"),
                    output_button(
                        port: port,
                        command: "WR MR35506 1\r",
                        buttonName: "上流出口扉開く"),
                    output_button(
                        port: port,
                        command: "WR MR35507 1\r",
                        buttonName: "上流出口扉閉める"),
                  ],
                ),
                Row(
                  children: [
                    output_button(
                        port: port,
                        command: "WR MR36203 1\r",
                        buttonName: "上流AIR GUN ON"),
                    output_button(
                        port: port,
                        command: "WR MR36203 0\r",
                        buttonName: "上流AIR GUN OFF"),
                    output_button(
                        port: port,
                        command: "WR MR35813 1\r",
                        buttonName: "エヤーガイド出す"),
                    output_button(
                        port: port,
                        command: "WR MR35813 0\r",
                        buttonName: "エヤーガイド引く"),
                    output_button(
                        port: port,
                        command: "WR MR35806 1\r",
                        buttonName: "トレー排除 UP"),
                    output_button(
                        port: port,
                        command: "WR MR35806 0\r",
                        buttonName: "トレー排除 UP"),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            // ボタン領域

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("戻る"),
            )
          ],
        ));

Widget output_button(
    {required port, required String command, required String buttonName}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: ElevatedButton(
        onPressed: () {
          port.write(Utf8Encoder().convert(command));
        },
        child: Text(buttonName)),
  );
}
