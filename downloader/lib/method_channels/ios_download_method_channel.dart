import 'package:flutter/services.dart';
import '../cubit/download_result_cubit.dart';
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
  final Map<String, DownloadListener> downloadListeners = {};

  static final IOSDownloadMethodChannel instance =
      IOSDownloadMethodChannel._init();

  IOSDownloadMethodChannel._init();

  DownloadResultCubit? downloadResultCubit ;
  init(DownloadResultCubit? downloadResultCubit) {
    _channelMethod = const MethodChannel(_iOSDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadResultCubit=downloadResultCubit;
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _iOSDownloadProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'],
            status: STATUS_DOWNLOAD_PROGRESS,
            progress: progress);
        publishDownloadResult(downloadEvent);
        if (downloadResultCubit != null) {
          downloadResultCubit?.publishProgress(url:url, progress: progress);
        }
        break;
      case _iOSDownloadCompleted:
        String url = methodData['url'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: url, status: STATUS_DOWNLOAD_COMPLETED);
        publishDownloadResult(downloadEvent);
        if (downloadResultCubit != null) {
          downloadResultCubit?.publishCompleted(url:url);
        }
        break;
      case _iOSDownloadError:
        String url = methodData['url'];
        String? error = methodData['error'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: url,
            status: STATUS_DOWNLOAD_ERROR,
            error: error);
        publishDownloadResult(downloadEvent);
        if (downloadResultCubit != null) {
          downloadResultCubit?.publishError(url:url,error: error);
        }
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
      downloadListeners[url] = downloadListener;
    }
  }
}
