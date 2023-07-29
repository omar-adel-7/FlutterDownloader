import 'package:flutter_test/flutter_test.dart';
import 'package:downloader/downloader.dart';
import 'package:downloader/downloader_platform_interface.dart';
import 'package:downloader/downloader_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDownloaderPlatform
    with MockPlatformInterfaceMixin
    implements DownloaderPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DownloaderPlatform initialPlatform = DownloaderPlatform.instance;

  test('$MethodChannelDownloader is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDownloader>());
  });

  test('getPlatformVersion', () async {
    Downloader downloaderPlugin = Downloader();
    MockDownloaderPlatform fakePlatform = MockDownloaderPlatform();
    DownloaderPlatform.instance = fakePlatform;

    expect(await downloaderPlugin.getPlatformVersion(), '42');
  });
}
