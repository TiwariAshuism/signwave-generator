import 'package:flutter/services.dart';

class AudioPlugin {
  static const MethodChannel _channel = MethodChannel('audio_plugin');
  
  static Future<void> start(double frequency) async {
    try {
      await _channel.invokeMethod('start', {'frequency': frequency});
    } catch (e) {
      print('Error starting audio: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }
}
