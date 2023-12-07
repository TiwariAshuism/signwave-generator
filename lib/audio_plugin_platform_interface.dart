import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_plugin_method_channel.dart';

abstract class AudioPluginPlatform extends PlatformInterface {
  /// Constructs a AudioPluginPlatform.
  AudioPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioPluginPlatform _instance = MethodChannelAudioPlugin();

  /// The default instance of [AudioPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioPlugin].
  static AudioPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioPluginPlatform] when
  /// they register themselves.
  static set instance(AudioPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
