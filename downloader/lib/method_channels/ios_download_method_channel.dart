import 'package:flutter/services.dart';
import '../download_event.dart';
import '../download_listener.dart';
import '../download_status_constants.dart';

class IOSDownloadMethodChannel {
  static const _iOSDownloadChannelName = 'iOSDownloadChannelName';
  static const _iOSStartDownload = 'iOSStartDownload';
  static const _iOSDownloadProgress = 'iOSDownloadProgress';
  static const _iOSDownloadCompleted = 'iOSDownloadCompleted';
  static const _iOSDownloadError = 'iOSDownloadError';

  MethodChannel? _channelMethod;
  final Map<String, List<DownloadListener>> downloadListeners = {};

  static final IOSDownloadMethodChannel instance =
      IOSDownloadMethodChannel._init();

  IOSDownloadMethodChannel._init();

  init() {
    _channelMethod = const MethodChannel(_iOSDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _iOSDownloadProgress:
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'],
            status: STATUS_DOWNLOAD_PROGRESS,
            progress: methodData['progress']);
        publishDownloadResult(downloadEvent);
        break;
      case _iOSDownloadCompleted:
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'], status: STATUS_DOWNLOAD_COMPLETED);
        publishDownloadResult(downloadEvent);
        break;
      case _iOSDownloadError:
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'],
            status: STATUS_DOWNLOAD_ERROR,
            error: methodData['error']);
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
      required String fileName,
      DownloadListener? downloadListener}) {
    addDownloadListener(url: url, downloadListener: downloadListener);
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationPath': destinationDirPath,
      'fileName': fileName
    });
    _channelMethod?.invokeMethod(_iOSStartDownload, argsMap);
  }

  void addDownloadListener(
      {required String url, DownloadListener? downloadListener}) {
    if (downloadListener != null) {
      downloadListeners[url] = [];
      downloadListeners[url]?.add(downloadListener);
    }
  }
}
