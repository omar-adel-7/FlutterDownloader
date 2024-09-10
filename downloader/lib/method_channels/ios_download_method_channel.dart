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
        String id = methodData['id'];
        String url = methodData['url'];
        int progress = methodData['progress'];
          downloadCubit.publishProgress(id:id,url:url, progress: progress,downloadListener: getIdDownloadListener(id));
        break;
      case _iOSDownloadCompleted:
        String id = methodData['id'];
        String url = methodData['url'];
          downloadCubit.publishCompleted(id:id,url:url,downloadListener: getIdDownloadListener(id));
        break;
      case _iOSDownloadError:
        String id = methodData['id'];
        String url = methodData['url'];
        String? error = methodData['error'];
          downloadCubit.publishError(id:id,url:url,error: error,downloadListener: getIdDownloadListener(id));
        break;
      default:
        break;
    }
  }

  DownloadListener? getIdDownloadListener(String id) {
    return downloadListeners[id];
  }

  downloadFile(
      {required String id,required String url,
      required String destinationDirPath,
      required String fileName,
        DownloadListener? downloadListener}) {
    addDownloadListener(id: id, downloadListener: downloadListener);
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'id': id,
      'url': url,
      'destinationPath': destinationDirPath,
      'fileName': fileName
    });
    _channelMethod?.invokeMethod(_iOSStartDownload, argsMap);
  }


  void addDownloadListener(
      {required String id, DownloadListener? downloadListener}) {
    if (downloadListener != null) {
      downloadListeners[id] = downloadListener;
    }
  }
}
