import 'package:flutter/services.dart';

import '../../cubit/download_cubit.dart';
import '../../downloader_plugin.dart';
import '../download_manager.dart';

class AndroidDownloadMethodChannel {
  static const _androidDownloadChannelName = 'download';
  static const _androidStart = 'start';
  static const _androidCancelSingle = 'cancelSingle';
  static const _androidCancelAll = 'cancelAll';
  static const _androidResultAdded = 'resultAdded';
  static const _androidResultProgress = 'resultProgress';
  static const _androidResultCanceled = 'resultCanceled';
  static const _androidResultCompleted = 'resultCompleted';
  static const _androidResultError = 'resultError';
  static const _androidResultGetInitialListData = 'resultGetInitialListData';

  MethodChannel? _channelMethod ;

  static final AndroidDownloadMethodChannel instance =
      AndroidDownloadMethodChannel._init();

  AndroidDownloadMethodChannel._init();

  late DownloadCubit downloadCubit;

  init(DownloadCubit downloadCubit) async {
    _channelMethod = const MethodChannel(_androidDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadCubit = downloadCubit;
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _androidResultGetInitialListData:
        String listData = methodData['listData'];
        downloadCubit.publishGotAndroidListData(listData);
        break;
        case _androidResultAdded:
        String listData = methodData['listData'];
        String url = methodData['url'];
        downloadCubit.publishAdded(url:url,androidListData:listData );
        break;
      case _androidResultProgress:
        String listData = methodData['listData'];
        String url = methodData['url'];
        int progress = methodData['progress'];
        downloadCubit.publishProgress(url: url, progress: progress,androidListData:listData);
        break;
      case _androidResultCanceled:
        String listData = methodData['listData'];
        String url = methodData['url'];
        downloadCubit.publishCanceled(url:url,androidListData:listData);
        break;
      case _androidResultCompleted:
        String listData = methodData['listData'];
        String url = methodData['url'];
        downloadCubit.publishCompleted(url: url,androidListData:listData);
        break;
      case _androidResultError:
        String listData = methodData['listData'];
        String url = methodData['url'];
        String? error = methodData['error'];
        downloadCubit.publishError(url: url, error: error,androidListData:listData);
        break;
      default:
        break;
    }
  }

  downloadFile({
    required String url,
    required String destinationDirPath,
    required String fileName,
    String? notificationMessage,
    String? notificationProgressMessage,
    String? notificationCompleteMessage
  }) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({
      'url': url,
      'destinationDirPath': destinationDirPath,
      'fileName': fileName,
      'notificationMessage': notificationMessage ?? fileName,
      'notificationProgressMessage': notificationProgressMessage,
      'notificationCompleteMessage': notificationCompleteMessage
    });
    _channelMethod?.invokeMethod(_androidStart, argsMap);
  }

  cancelDownloadFile(String url) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({'url': url});
    _channelMethod?.invokeMethod(_androidCancelSingle, argsMap);
  }

  cancelDownloads() {
    _channelMethod?.invokeMethod(_androidCancelAll);
  }
}
