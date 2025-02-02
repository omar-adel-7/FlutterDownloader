import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/services.dart';

import '../../cubit/download_cubit.dart';
import '../download_manager.dart';
import '../download_model.dart';
import '../ios_local_notifications_util.dart';

class IOSDownloadMethodChannel {
  static const _iOSDownloadChannelName = 'download';
  static const _iOSStart = 'start';
  static const _iosCancelSingle = 'cancelSingle';
  static const _iosCancelAll = 'cancelAll';
  static const _iOSDownloadResultProgress = 'resultProgress';
  static const _iOSDownloadResultCanceled = 'resultCanceled';
  static const _iOSDownloadResultCompleted = 'resultCompleted';
  static const _iOSDownloadResultError = 'resultError';

  MethodChannel? _channelMethod;

  static final IOSDownloadMethodChannel instance =
      IOSDownloadMethodChannel._init();

  IOSDownloadMethodChannel._init();

  late DownloadCubit downloadCubit;

  IosLocalNotificationsUtil? iosLocalNotificationsUtil;
  Map<String, int> notificationsMap = {};
  int notificationId = 0;

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
        if (DownloaderPlugin.showIosNotifications) {
          DownloadModel? downloadModel =
              DownloadManager().getDownloadIfExist(url);
          if (downloadModel != null) {
            if (notificationsMap[url] == null) {
              notificationId++;
              iosLocalNotificationsUtil?.showNotification(
                  id: notificationId,
                  body: "${downloadModel.iosNotificationProgressMessage ??
                      DownloaderPlugin.notificationProgressMessage} ${downloadModel.iosNotificationMessage}");
              notificationsMap[url] = notificationId;
            }
          }
        }
        downloadCubit.publishProgress(url: url, progress: progress);
        break;
      case _iOSDownloadResultCanceled:
        String url = methodData['url'];
        if (DownloaderPlugin.showIosNotifications) {
          if (notificationsMap[url] != null) {
            iosLocalNotificationsUtil
                ?.cancelNotification(notificationsMap[url]!);
            notificationsMap.remove(url);
          }
        }
        break;
      case _iOSDownloadResultCompleted:
        String url = methodData['url'];
        if (DownloaderPlugin.showIosNotifications) {
          DownloadModel? downloadModel =
              DownloadManager().getDownloadIfExist(url);
          if (downloadModel != null) {
            if (notificationsMap[url] != null) {
              iosLocalNotificationsUtil?.showNotification(
                  id: notificationsMap[url]!,
                  body: "${downloadModel.iosNotificationCompleteMessage ??
                      DownloaderPlugin.notificationCompleteMessage} ${downloadModel.iosNotificationMessage}");
              notificationsMap.remove(url);
            }
          }
        }
        downloadCubit.publishCompleted(url: url);
        break;
      case _iOSDownloadResultError:
        String url = methodData['url'];
        if (DownloaderPlugin.showIosNotifications) {
          if (notificationsMap[url] != null) {
            iosLocalNotificationsUtil
                ?.cancelNotification(notificationsMap[url]!);
            notificationsMap.remove(url);
          }
        }
        String? error = methodData['error'];
        downloadCubit.publishError(url: url, error: error);
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
    _channelMethod?.invokeMethod(_iOSStart, argsMap);
  }

  cancelDownloadFile(String url) {
    Map argsMap = <dynamic, dynamic>{};
    argsMap.addAll({'url': url});
    _channelMethod?.invokeMethod(_iosCancelSingle, argsMap);
  }

  cancelDownloads() {
    _channelMethod?.invokeMethod(_iosCancelAll);
  }
}
