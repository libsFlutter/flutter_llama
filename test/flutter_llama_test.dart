import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:flutter_llama/flutter_llama_platform_interface.dart';
import 'package:flutter_llama/flutter_llama_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLlamaPlatform
    with MockPlatformInterfaceMixin
    implements FlutterLlamaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterLlamaPlatform initialPlatform = FlutterLlamaPlatform.instance;

  test('$MethodChannelFlutterLlama is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterLlama>());
  });

  test('getPlatformVersion', () async {
    FlutterLlama flutterLlamaPlugin = FlutterLlama();
    MockFlutterLlamaPlatform fakePlatform = MockFlutterLlamaPlatform();
    FlutterLlamaPlatform.instance = fakePlatform;

    expect(await flutterLlamaPlugin.getPlatformVersion(), '42');
  });
}
