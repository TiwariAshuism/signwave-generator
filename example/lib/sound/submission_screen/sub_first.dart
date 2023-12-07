import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioPlayerWidget extends StatefulWidget {
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('audio_plugin');
  double frequency = 1.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startAudio();
    WidgetsBinding.instance.addObserver(this);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.paused) {
      // App is in the background, stop the audio
      _stopAudio();
    } else if (state == AppLifecycleState.resumed) {
      // App is back to the foreground, start or resume the audio as needed
      _startAudio();
    }
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
                    'Frequency: ${frequency.toInt()} Hz',
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
                      value: frequency,
                      min: 1.0,
                      max: 100.0,
                      onChangeEnd: (value) {
                        frequency = value;
                        setState(() {});
                        _startAudio();
                      },
                      onChanged: (double value) {},
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startAudio() async {
    try {
      await _channel.invokeMethod('start', {'frequency': frequency});
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
    WidgetsBinding.instance.removeObserver(this);
    _stopAudio();
    super.dispose();
  }
}
