import 'package:flutter/services.dart';

import '../../cubit/download_cubit.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStartDownload = 'startDownload';
  static const _androidCancelDownload = 'cancelDownload';
  static const _androidCancelDownloads = 'cancelDownloads';
  static const _androidDownloadResultProgress = 'downloadResultProgress';
  static const _androidDownloadResultCompleted = 'downloadResultCompleted';
  static const _androidDownloadResultError = 'downloadResultError';

  MethodChannel? _channelMethod;

  static final AndroidDownloadMethodChannel instance =
      AndroidDownloadMethodChannel._init();

  AndroidDownloadMethodChannel._init();

  late DownloadCubit downloadCubit;

   init(DownloadCubit downloadCubit) {
    _channelMethod = const MethodChannel(_androidDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadCubit = downloadCubit;
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _androidDownloadResultProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
        downloadCubit.publishProgress(
            url: url,
            progress: progress);
        break;
      case _androidDownloadResultCompleted:
        String url = methodData['url'];
        downloadCubit.publishCompleted(url: url);
        break;
      case _androidDownloadResultError:
        String url = methodData['url'];
        String? error = methodData['error'];
        downloadCubit.publishError(
            url: url,
            error: error);
        break;
      default:
        break;
    }
  }

  downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileName,
      required String notificationMessage,
      required String notificationProgressMessage,
      required String notificationCompleteMessage,
      }) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationDirPath': destinationDirPath,
      'fileName': fileName,
      'notificationMessage': notificationMessage,
      'notificationProgressMessage': notificationProgressMessage,
      'notificationCompleteMessage': notificationCompleteMessage,
    });
    _channelMethod?.invokeMethod(_androidStartDownload, argsMap);
    downloadCubit.publishStarted(
        url: url);
  }

  cancelDownloadFile(String url) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url
    });
    _channelMethod?.invokeMethod(_androidCancelDownload,argsMap);
  }

  cancelDownloads() {
    _channelMethod?.invokeMethod(_androidCancelDownloads);
  }


}
