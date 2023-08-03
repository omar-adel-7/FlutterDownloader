import 'package:flutter/services.dart';
import '../download_event.dart';
import '../download_listener.dart';
import '../download_util.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStartDownload = 'startDownload';
  static const _androidDownloadResult = 'downloadResult';

  MethodChannel? _channelMethod;
  final Map<String, List<DownloadListener>> downloadListeners = {};

  static final AndroidDownloadMethodChannel instance =
      AndroidDownloadMethodChannel._init();

  AndroidDownloadMethodChannel._init();

  init() {
    _channelMethod = const MethodChannel(_androidDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _androidDownloadResult:
        DownloadEvent downloadEvent =
            DownloadEvent(url: methodData['url'], status: methodData['status']);
        int progress = 0;
        if (isNumber(downloadEvent.status)) {
          progress = int.parse(downloadEvent.status!);
        }
        downloadEvent = DownloadEvent(
            url: downloadEvent.url,
            status: downloadEvent.status,
            progress: progress,
            error: downloadEvent.error);
        publishDownloadResult(downloadEvent);
        break;
      default:
        break;
    }
  }

  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadListeners[downloadEvent.url] != null) {
      for (int i = 0; i < downloadListeners[downloadEvent.url]!.length; i++) {
        downloadListeners[downloadEvent.url]?[i]
            .publishDownloadResult(downloadEvent);
      }
    }
  }

  downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String notificationMessage,
      required String notificationProgressMessage,
      required String notificationCompleteMessage,
      required String errorMessage,
      DownloadListener? downloadListener}) {
    addDownloadListener(url, downloadListener);
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationDirPath': destinationDirPath,
      'fileNameWithoutExtension': fileNameWithoutExtension,
      'extension': extension,
      'notificationMessage': notificationMessage,
      'notificationProgressMessage': notificationProgressMessage,
      'notificationCompleteMessage': notificationCompleteMessage,
      'errorMessage': errorMessage,
    });
    _channelMethod?.invokeMethod(_androidStartDownload, argsMap);
  }

  void addDownloadListener(String url, DownloadListener? downloadListener) {
    if (downloadListener != null) {
      if (downloadListeners[url] == null) {
        downloadListeners[url] = [];
      }
      downloadListeners[url]?.add(downloadListener);
    }
  }
}
