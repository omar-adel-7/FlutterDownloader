import '../downloader_plugin.dart';
import '../download_model.dart';
import 'download_util.dart';
import 'method_channels/ios_download_method_channel.dart';

class DownloadManager {
  DownloadManager._();

  static final DownloadManager _instance = DownloadManager._();

  factory DownloadManager() {
    return _instance;
  }

  static final DownloadManager instance = DownloadManager._();

  List<DownloadModel> list = [];

  downloadFile(
      {required String url,
      required String destinationPath,
      required String fileName,
        String? androidNotificationMessage}) {
    if (!isInDownloadList(url)) {
      if (DownloaderPlugin.isPlatformAndroid()) {
        DownloadUtil.startAndroidDownload(
            url: url,
            destinationPath: destinationPath,
            fileName: fileName,
            notificationMessage: androidNotificationMessage);
      } else if (DownloaderPlugin.isPlatformIos()) {
        list.add(DownloadModel(
          url: url,
          destinationPath: destinationPath,
          fileName: fileName,
        ));
        IOSDownloadMethodChannel.instance.downloadCubit.publishAdded(url:url);
        if (DownloaderPlugin.isSerial) {
          if (getDownloadsCount() == 1) {
            DownloadUtil.startIosDownload(
                url: url, destinationPath: destinationPath, fileName: fileName);
          }
        } else {
          DownloadUtil.startIosDownload(
              url: url, destinationPath: destinationPath, fileName: fileName);
        }
      }
    }
  }

  cancelUrlDownload(String url) {
    DownloadUtil.cancelUrlDownload(url);
    if (DownloaderPlugin.isPlatformIos()) {
      if (DownloaderPlugin.isSerial) {
        if (_iosIfCurrentlyDownloading(url)) {
          iosRemoveDownload(url);
          DownloadUtil.sendIosCanceled(url);
          iosCheckToDownloadNext();
        } else {
          iosRemoveDownload(url);
          DownloadUtil.sendIosCanceled(url);
        }
      } else {
        iosRemoveDownload(url);
        DownloadUtil.sendIosCanceled(url);
      }
    }
  }

  cancelMultiUrlsDownload(List<String> urlsList) {
    bool foundCurrentlyDownloadingLink = false;
    for (String url in urlsList) {
      DownloadModel? downloadModel = getDownloadIfExist(url);
      if (downloadModel != null) {
        DownloadUtil.cancelUrlDownload(url);
        if (DownloaderPlugin.isPlatformIos()) {
          if (DownloaderPlugin.isSerial) {
            if (_iosIfCurrentlyDownloading(url)) {
              foundCurrentlyDownloadingLink = true;
              iosRemoveDownload(url);
              DownloadUtil.sendIosCanceled(url);
            } else {
              iosRemoveDownload(url);
              DownloadUtil.sendIosCanceled(url);
            }
          } else {
            iosRemoveDownload(url);
            DownloadUtil.sendIosCanceled(url);
          }
        }
      }
    }
    if (foundCurrentlyDownloadingLink) {
      iosCheckToDownloadNext();
    }
  }

  getAndroidList(String? listData) {
    list.clear();
    if(listData?.isNotEmpty==true)
    {
      List<String> tempList  = listData?.split(DownloaderPlugin.DOWNLOADER_LIST_DIVIDER_KEY)??[];
      tempList.removeLast();
      for (int i = 0; i < tempList.length; i++) {
        List<String> tempItemList =  tempList[i].split(DownloaderPlugin.DOWNLOADER_LIST_ITEM_INTERNAL_KEY);
        DownloadModel downloadModel = DownloadModel(url: tempItemList[0] ,
            progress: int.parse(tempItemList[1]));
        list.add(downloadModel);
      }
    }
  }

  updateIosProgress(String url, int progress) {
    int index = list.indexWhere((element) => element.url == url);
    ((index != -1) && (index < list.length))
        ? list[index].progress = progress
        : null;
  }

  iosRemoveDownload(String url) {
    list.removeWhere((item) => item.url == url);
  }

  iosCheckToDownloadNext() {
    if (isDownloadsNotEmpty()) {
      DownloadModel downloadModel = list[0];
      DownloadUtil.startIosDownload(
          url: downloadModel.url,
          destinationPath: downloadModel.destinationPath,
          fileName: downloadModel.fileName);
    }
  }

  bool _iosIfCurrentlyDownloading(String url) {
    return list.isNotEmpty ? list[0].url == url : false;
  }

  bool isInDownloadList(String url) {
    return getDownloadIfExist(url) != null;
  }

  DownloadModel? getDownloadIfExist(String url) {
    for (var downloadModel in list) {
      if (downloadModel.url == url) return downloadModel;
    }
    return null;
  }

  bool isDownloadsNotEmpty() {
    bool isDownloadsNotEmpty = list.isNotEmpty;
    //print("isDownloadsNotEmpty = $isDownloadsNotEmpty");
    return isDownloadsNotEmpty;
  }

  int getDownloadsCount() {
    //print("getDownloadsCount list.length=${list.length}");
    return list.length;
  }

  clearDownloadsList() {
    list.clear();
  }
}
