import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class SubmissionFirst extends StatefulWidget {
  final writeC;
  var device;
  final frequency;
  SubmissionFirst(
      {super.key, this.writeC, required this.device, this.frequency});
  @override
  _SubmissionFirstState createState() => _SubmissionFirstState();
}

class _SubmissionFirstState extends State<SubmissionFirst> {
  StreamController<bool> visibilityController = StreamController<bool>();
  static const MethodChannel _channel = MethodChannel('audio_plugin');
  double frequency = 1.0;
  @override
  void initState() {
    super.initState();

    // Set an initial value for visibility
    visibilityController.add(false);
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop:false,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: const Color.fromARGB(194, 255, 255, 255),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                      height: 20,
                    ),
                    Center(
                      child: MaterialButton(
                        focusColor: Colors.white,
                        child: Text(
                          "Play",
                          style: TextStyle(color: Colors.white),
                          selectionColor: Colors.white,
                        ),
                        onPressed: () async {
                          sendCommandStart(170);

                          await _startAudio();
                        },
                      ),
                    ),
                    SizedBox(width: 24),
                    MaterialButton(
                      child: Text(
                        "Stop",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        sendCommandStop(255);
                        _stopAudio();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: visibilityController.stream,
          initialData: false,
          builder: (context, snapshot) {
            bool isVisible = snapshot.data ?? false;

            return Visibility(
              visible: isVisible,
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
            );
          },
        ),
      ),
    );
  }

  sendCommandStart(int numvalue) {
    widget.writeC?.write([numvalue]);
    print(widget.writeC);
    visibilityController.add(false);
  }

  sendCommandStop(int numvalue) {
    print(widget.writeC);
    widget.writeC?.write([numvalue]);
    visibilityController.add(true);
  }

  Future<void> _startAudio() async {
    try {
      await _channel.invokeMethod('start', {'frequency': widget.frequency});
    } catch (e) {
      print('Error starting audio: $e');
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  void dispose() {
    _stopAudio();
    super.dispose();
    visibilityController.close();
  }
}
