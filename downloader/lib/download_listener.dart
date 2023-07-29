import 'package:fluttertoast/fluttertoast.dart';

import 'download_event.dart';
import 'download_status_constants.dart';
import 'download_utils.dart';

class DownloadListener {

  final Function(String url, int progress)? onProgress ;
  final Function(String url)? onComplete ;
  final Function(String url)? onError ;

  DownloadListener({required this.onProgress,
    required this.onComplete,
    required this.onError});

  String? iosErrorMessage = "error in download";

  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadEvent.status == STATUS_DOWNLOAD_ERROR ||
        downloadEvent.status == STATUS_DOWNLOAD_REMOVED) {
      if (isPlatformIos()) {
        showToast(iosErrorMessage!);
      }
      onError!(downloadEvent.url!);
    }
    else if (downloadEvent.status ==
        STATUS_DOWNLOAD_FOREGROUND_EXCEPTION) {
      onError!(downloadEvent.url!);
    }
    else if (downloadEvent.status == STATUS_DOWNLOAD_COMPLETED) {
      onComplete!(downloadEvent.url!);
    }  else {
      onProgress!(downloadEvent.url!, downloadEvent.progress);
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }
}
