import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStartDownload = 'startDownload';
  static const _androidDownloadResultProgress = 'downloadResultProgress';
  static const _androidDownloadResultCompleted = 'downloadResultCompleted';
  static const _androidDownloadResultError = 'downloadResultError';

  static const _androidStopDownloadService = 'stopDownloadService';

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
        String id = methodData['id'];
        String url = methodData['url'];
        int progress = methodData['progress'];
        downloadCubit.publishProgress(
            id: id,
            url: url,
            progress: progress);
        break;
      case _androidDownloadResultCompleted:
        String id = methodData['id'];
        String url = methodData['url'];
        downloadCubit.publishCompleted(
            id: id, url: url);
        break;
      case _androidDownloadResultError:
        String id = methodData['id'];
        String url = methodData['url'];
        String? error = methodData['error'];
        downloadCubit.publishError(
            id: id,
            url: url,
            error: error);
        break;
      default:
        break;
    }
  }

  downloadFile(
      {required String id,
      required String url,
      required String destinationDirPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String notificationMessage,
      required String notificationProgressMessage,
      required String notificationCompleteMessage,
      }) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'id': id,
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

  stopService() {
    _channelMethod?.invokeMethod(_androidStopDownloadService);
  }

}
