import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ignore: must_be_immutable
class SubmissionFirstLightOnly extends StatefulWidget {
  final BluetoothCharacteristic? readC;
  final BluetoothCharacteristic? writeC;
  var device;
  final double frequency;
  SubmissionFirstLightOnly(
      {Key? key,
      required this.device,
      this.readC,
      this.writeC,
      required this.frequency})
      : super(key: key);

  @override
  State<SubmissionFirstLightOnly> createState() =>
      _SubmissionFirstLightOnlyState();
}

class _SubmissionFirstLightOnlyState extends State<SubmissionFirstLightOnly> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: const Color.fromARGB(194, 255, 255, 255),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(3, -0.3),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 27, 186, 186)),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(-3, -0.3),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 183, 58, 141)),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0, -1.2),
                  child: Container(
                    height: 300,
                    width: 600,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 64, 112, 255)),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(220, 240, 240, 240),
                              Color.fromARGB(220, 202, 202, 202),
                            ],
                            stops: [0.0, 1.0],
                            transform: GradientRotation(
                              145 * (3.141592653589793 / 180.0),
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(5, 5),
                              blurRadius: 40,
                              color: Color(0xFF828282),
                            ),
                            BoxShadow(
                              offset: Offset(-5, -5),
                              blurRadius: 40,
                              color: Color(0xFFFFFFFF),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Text(
                                isSwitched ? "Stop" : "Start",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Switch(
                                value: isSwitched,
                                onChanged: (value) {
                                  isSwitched = value;
                                  isSwitched
                                      ? sendCommandStart(170)
                                      : sendCommandStop(255);
                                  setState(() {});
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible: !isSwitched,
          child: FloatingActionButton(
            onPressed: () {
              widget.writeC?.write([237]);
              Future.delayed(Duration(seconds: 1));
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 3;
              });
            },
            child: Icon(Icons.restart_alt),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  sendCommandStart(numvalue) {
    widget.writeC?.write([numvalue]);
  }

  sendCommandStop(numvalue) {
    widget.writeC?.write([numvalue]);
  }
}
