import 'package:flutter_test/flutter_test.dart';
import 'package:audio_plugin/audio_plugin.dart';
import 'package:audio_plugin/audio_plugin_platform_interface.dart';
import 'package:audio_plugin/audio_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioPluginPlatform
    with MockPlatformInterfaceMixin
    implements AudioPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioPluginPlatform initialPlatform = AudioPluginPlatform.instance;

  test('$MethodChannelAudioPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioPlugin>());
  });

  test('getPlatformVersion', () async {
    AudioPlugin audioPlugin = AudioPlugin();
    MockAudioPluginPlatform fakePlatform = MockAudioPluginPlatform();
    AudioPluginPlatform.instance = fakePlatform;
  });
}
