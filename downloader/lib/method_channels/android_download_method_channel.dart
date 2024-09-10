import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';
import '../download_listener.dart';

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

  late DownloadCubit downloadCubit ;
  init(DownloadCubit downloadCubit) {
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
          downloadCubit.publishProgress(url:url, progress: progress,downloadListener: getUrlDownloadListener(url));
        break;
      case _androidDownloadResultCompleted:
        String url = methodData['url'];
          downloadCubit.publishCompleted(url:url,downloadListener: getUrlDownloadListener(url));
        break;
      case _androidDownloadResultError:
        String url = methodData['url'];
        String? error = methodData['error'];
          downloadCubit.publishError(url:url,error: error,downloadListener: getUrlDownloadListener(url));
        break;
      default:
        break;
    }
  }


  DownloadListener? getUrlDownloadListener(String url) {
    return downloadListeners[url];
  }

  downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String notificationMessage,
      required String notificationProgressMessage,
      required String notificationCompleteMessage,
        DownloadListener? downloadListener
      }) {
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
