import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';
import '../download_event.dart';
import '../download_listener.dart';
import '../download_status_constants.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStartDownload = 'startDownload';
  static const _androidDownloadResultProgress = 'downloadResultProgress';
  static const _androidDownloadResultCompleted = 'downloadResultCompleted';
  static const _androidDownloadResultError = 'downloadResultError';

  static const _androidIsFileDownloading = 'isDownloading';
  static const _androidCancelAndClearDownloads = 'cancelAndClearDownloads';

  MethodChannel? _channelMethod;
  final Map<String, DownloadListener> downloadListeners = {};

  static final AndroidDownloadMethodChannel instance =
      AndroidDownloadMethodChannel._init();

  AndroidDownloadMethodChannel._init();

  DownloadCubit? downloadCubit ;
  init(DownloadCubit? downloadCubit) {
    _channelMethod = const MethodChannel(_androidDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadCubit=downloadCubit;
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _androidDownloadResultProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: methodData['url'],
            status: STATUS_DOWNLOAD_PROGRESS,
            progress: progress);
        publishDownloadResult(downloadEvent);
        if (downloadCubit != null) {
          downloadCubit?.publishProgress(url:url, progress: progress);
        }
        break;
      case _androidDownloadResultCompleted:
        String url = methodData['url'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: url, status: STATUS_DOWNLOAD_COMPLETED);
        publishDownloadResult(downloadEvent);
        if (downloadCubit != null) {
          downloadCubit?.publishCompleted(url:url);
        }
        break;
      case _androidDownloadResultError:
        String url = methodData['url'];
        String? error = methodData['error'];
        DownloadEvent downloadEvent = DownloadEvent(
            url: url,
            status: STATUS_DOWNLOAD_ERROR,
            error: error);
        publishDownloadResult(downloadEvent);
        if (downloadCubit != null) {
          downloadCubit?.publishError(url:url,error: error);
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
