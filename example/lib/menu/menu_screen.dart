import 'dart:io';
import 'dart:ui';

import 'package:audio_plugin_example/sound/submission_screen/sub_first.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lottie/lottie.dart';

import '../both/frequency/frequency_screen.dart';
import '../light/frequency/frequency_screen.dart';

// ignore: must_be_immutable
class MenuScreen extends StatefulWidget {
  var device;

  MenuScreen({super.key, this.device});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic? readC;
  BluetoothCharacteristic? writeC;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState

    _initializeBluetooth();

    super.initState();
  }

  Future<void> _initializeBluetooth() async {
    try {
      await widget.device.connect();
    } catch (e) {
      await widget.device.disconnect();
      await widget.device.connect();
    }

    await Future.delayed(Duration(seconds: 2));

    if (Platform.isAndroid) {
      await Future.delayed(Duration(seconds: 2));
      widget.device?.requestMtu(512);
    }

    List<BluetoothService>? services = await widget.device?.discoverServices();
    List<BluetoothCharacteristic>? list = services
        ?.map((s) => s.characteristics)
        .expand((element) => element)
        .toList();

    readC = list?.firstWhere((element) =>
        element.uuid.toString() == "49535343-1e4d-4bd9-ba61-23c647249616");
    writeC = list?.firstWhere((element) =>
        element.uuid.toString() == "49535343-8841-43f4-a8d4-ecbe34729bb3");
    setState(() {
      isLoading = false; // Set loading to false after initialization
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: const Color.fromARGB(194, 255, 255, 255),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: isLoading
          ? Center(
              child: CustomCircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
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
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FrequencyScreenLightOnly(
                                        device: widget.device,
                                        writeC: writeC,
                                        readC: readC,
                                      )),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/a.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Visual Only',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.light,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioPlayerWidget(),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: MediaQuery.of(context).size.width - 50,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/a.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sound Only',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.speaker,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FrequencyScreen(
                                        device: widget.device,
                                        writeC: writeC,
                                        readC: readC,
                                      )),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/a.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Light + Sound',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.graphic_eq,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  CustomCircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset('assets/images/Animation.json',
                    fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "We are loading main screen for you",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      ),
    );
  }
}
