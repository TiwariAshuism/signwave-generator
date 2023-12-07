import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_plugin_platform_interface.dart';

/// An implementation of [AudioPluginPlatform] that uses method channels.
class MethodChannelAudioPlugin extends AudioPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
