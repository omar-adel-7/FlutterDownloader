import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/services.dart';

import '../../cubit/download_cubit.dart';
import '../download_manager.dart';
import '../download_model.dart';
import '../ios_local_notifications_util.dart';

class IOSDownloadMethodChannel {
  static const _iOSDownloadChannelName = 'iOSDownloadChannelName';
  static const _iOSStartDownload = 'iOSStartDownload';
  static const _iosCancelDownload = 'cancelDownload';
  static const _iOSDownloadResultProgress = 'iOSDownloadProgress';
  static const _iOSDownloadResultCompleted = 'iOSDownloadCompleted';
  static const _iOSDownloadResultError = 'iOSDownloadError';

  MethodChannel? _channelMethod;

  static final IOSDownloadMethodChannel instance =
      IOSDownloadMethodChannel._init();

  IOSDownloadMethodChannel._init();

  late DownloadCubit downloadCubit;

  IosLocalNotificationsUtil? iosLocalNotificationsUtil;

  init(DownloadCubit downloadCubit) {
    _channelMethod = const MethodChannel(_iOSDownloadChannelName);
    _channelMethod?.setMethodCallHandler(methodHandler);
    this.downloadCubit = downloadCubit;
    if (DownloaderPlugin.showIosNotifications) {
      iosLocalNotificationsUtil = IosLocalNotificationsUtil();
    }
  }

  Future<void> methodHandler(MethodCall call) async {
    final Map methodData = call.arguments;
    switch (call.method) {
      case _iOSDownloadResultProgress:
        String url = methodData['url'];
        int progress = methodData['progress'];
        downloadCubit.publishProgress(url: url, progress: progress);
        if (DownloaderPlugin.showIosNotifications) {
          DownloadModel? downloadModel =
              DownloadManager().getDownloadIfExist(url);
          if (downloadModel != null) {
            int? index = DownloadManager().getDownloadIndexIfExist(url);
            if (index != null) {
              iosLocalNotificationsUtil?.showNotification(
                  id: index + 1,
                  body: downloadModel.iosNotificationProgressMessage ??
                      "${DownloaderPlugin.notificationProgressMessage} "
                          "${downloadModel.iosNotificationMessage}");
            }
          }
        }

        break;
      case _iOSDownloadResultCompleted:
        String url = methodData['url'];
        downloadCubit.publishCompleted(url: url);
        if (DownloaderPlugin.showIosNotifications) {
          DownloadModel? downloadModel =
              DownloadManager().getDownloadIfExist(url);
          if (downloadModel != null) {
            int? index = DownloadManager().getDownloadIndexIfExist(url);
            if (index != null) {
              iosLocalNotificationsUtil?.showNotification(
                  id: index + 1,
                  body: downloadModel.iosNotificationCompleteMessage ??
                      "${DownloaderPlugin.notificationCompleteMessage} "
                          "${downloadModel.iosNotificationMessage}");
            }
          }
        }
        break;
      case _iOSDownloadResultError:
        String url = methodData['url'];
        String? error = methodData['error'];
        if (error?.contains("cancel") == false) {
          downloadCubit.publishError(url: url, error: error);
        }
        if (DownloaderPlugin.showIosNotifications) {
          int? index = DownloadManager().getDownloadIndexIfExist(url);
          if (index != null) {
            iosLocalNotificationsUtil?.cancelNotification(index + 1);
          }
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

  cancelDownloadFile(String url) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({'url': url});
    _channelMethod?.invokeMethod(_iosCancelDownload, argsMap);
  }
}
