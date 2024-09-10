import 'package:flutter/services.dart';
import '../cubit/download_cubit.dart';
import '../download_status_constants.dart';

class IOSDownloadMethodChannel {
  static const _iOSDownloadChannelName = 'iOSDownloadChannelName';
  static const _iOSStartDownload = 'iOSStartDownload';
  static const _iOSDownloadProgress = 'iOSDownloadProgress';
  static const _iOSDownloadCompleted = 'iOSDownloadCompleted';
  static const _iOSDownloadError = 'iOSDownloadError';

  MethodChannel? _channelMethod;

  static final IOSDownloadMethodChannel instance =
      IOSDownloadMethodChannel._init();

  IOSDownloadMethodChannel._init();

  DownloadCubit? downloadCubit ;
  init(DownloadCubit? downloadCubit) {
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
        if (downloadCubit != null) {
          downloadCubit?.publishProgress(url:url, progress: progress);
        }
        break;
      case _iOSDownloadCompleted:
        String url = methodData['url'];
        if (downloadCubit != null) {
          downloadCubit?.publishCompleted(url:url);
        }
        break;
      case _iOSDownloadError:
        String url = methodData['url'];
        String? error = methodData['error'];
        if (downloadCubit != null) {
          downloadCubit?.publishError(url:url,error: error);
        }
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
  }

}
