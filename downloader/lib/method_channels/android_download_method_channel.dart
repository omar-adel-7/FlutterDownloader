import 'package:flutter/services.dart';
import '../download_event.dart';
import '../download_listener.dart';
import '../download_util.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStartDownload = 'startDownload';
  static const _androidDownloadResult = 'downloadResult';
  static const _androidIsFileDownloading = 'isDownloading';
  static const _androidCancelAndClearDownloads = 'cancelAndClearDownloads';

  MethodChannel? _channelMethod;
  final Map<String, DownloadListener> downloadListeners = {};

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
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'],
            status: methodData['status'],
            progress: methodData['progress']);
        publishDownloadResult(downloadEvent);
        break;
      default:
        break;
    }
  }

  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadListeners[downloadEvent.url] != null) {
      downloadListeners[downloadEvent.url]
          ?.publishDownloadResult(downloadEvent);
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
      DownloadListener? downloadListener}) {
    addDownloadListener(url: url, downloadListener: downloadListener);
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationDirPath': destinationDirPath,
      'fileNameWithoutExtension': fileNameWithoutExtension,
      'extension': extension,
      'notificationMessage': notificationMessage,
      'notificationProgressMessage': notificationProgressMessage,
      'notificationCompleteMessage': notificationCompleteMessage,
    });
    _channelMethod?.invokeMethod(_androidStartDownload, argsMap);
  }

  void addDownloadListener(
      {required String url, DownloadListener? downloadListener}) {
    if (downloadListener != null) {
      downloadListeners[url] = downloadListener;
    }
  }

  Future<bool> isFileDownloading(String url) async {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url
    });
    return await _channelMethod?.invokeMethod(_androidIsFileDownloading, argsMap);
  }


  cancelAndClearDownloads() {
    _channelMethod?.invokeMethod(_androidCancelAndClearDownloads);
  }
}
