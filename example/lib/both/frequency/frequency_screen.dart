import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../duty_screen/DutyCycle.dart';


class FrequencyScreen extends StatefulWidget {
  var device;
  final writeC;
  final readC;
  FrequencyScreen({super.key, required this.device, this.writeC, this.readC});

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  double _sliderValue = 15.0;

  @override
  void initState() {
    super.initState();
  }

  @override
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Frequency Value: ${_sliderValue.toInt()}',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                  SizedBox(height: 20.0),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.white,
                      thumbColor: Colors.blue,
                      overlayColor: Colors.blue.withAlpha(50),
                      valueIndicatorColor: Colors.blue,
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                    ),
                    child: Slider(
                      value: _sliderValue,
                      min: 1,
                      max: 100,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      sendCommand(_sliderValue.toInt());
                      Get.to(() => DutyCycle(
                          device: widget.device,
                          readC: widget.readC,
                          writeC: widget.writeC,
                          frequency: _sliderValue));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(220, 240, 240, 240),
                            Color.fromARGB(220, 202, 202, 202)
                          ],
                          stops: [0.0, 1.0],
                          transform: GradientRotation(
                              145 * (3.141592653589793 / 180.0)),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 40,
                        ),
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

  Future<void> sendCommand(int numValue) async {
    widget.writeC?.write([numValue]);
    await Future.delayed(const Duration(seconds: 1), () {});
  }
}
