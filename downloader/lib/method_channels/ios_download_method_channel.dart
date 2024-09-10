import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';
import '../download_listener.dart';

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

  late DownloadCubit downloadCubit ;
  init(DownloadCubit downloadCubit) {
    _channelMethod = const MethodChannel(_iOSDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadCubit=downloadCubit;
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _iOSDownloadProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
          downloadCubit.publishProgress(url:url, progress: progress,downloadListener: getUrlDownloadListener(url));
        break;
      case _iOSDownloadCompleted:
        String url = methodData['url'];
          downloadCubit.publishCompleted(url:url,downloadListener: getUrlDownloadListener(url));
        break;
      case _iOSDownloadError:
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
