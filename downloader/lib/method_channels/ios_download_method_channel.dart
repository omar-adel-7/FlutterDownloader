import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';

class IOSDownloadMethodChannel {
  static const _iOSDownloadChannelName = 'iOSDownloadChannelName';
  static const _iOSStartDownload = 'iOSStartDownload';
  static const _iosCancelDownloads = 'cancelDownloads';
  static const _iOSDownloadResultProgress = 'iOSDownloadProgress';
  static const _iOSDownloadResultCompleted = 'iOSDownloadCompleted';
  static const _iOSDownloadResultError = 'iOSDownloadError';

  MethodChannel? _channelMethod;

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
      case _iOSDownloadResultProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
          downloadCubit.publishProgress(url:url, progress: progress);
        break;
      case _iOSDownloadResultCompleted:
        String url = methodData['url'];
          downloadCubit.publishCompleted(url:url);
        break;
      case _iOSDownloadResultError:
        String url = methodData['url'];
        String? error = methodData['error'];
          downloadCubit.publishError(url:url,error: error);
        break;
      default:
        break;
    }
  }

  downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileName}) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationPath': destinationDirPath,
      'fileName': fileName
    });
    _channelMethod?.invokeMethod(_iOSStartDownload, argsMap);
    downloadCubit.publishStarted(
        url: url);
  }

  cancelDownloads() {
    _channelMethod?.invokeMethod(_iosCancelDownloads);
  }

}
