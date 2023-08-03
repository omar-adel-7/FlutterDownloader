
import 'package:fluttertoast/fluttertoast.dart';

import 'download_event.dart';
import 'download_status_constants.dart';
import 'download_util.dart';

class DownloadListener {

  final Function(String url, int progress)? onProgress ;
  final Function(String url)? onComplete ;
  final Function(String url)? onError ;
  final String iosErrorMessage;
  DownloadListener({required this.onProgress,
    required this.onComplete,
    required this.onError,required this.iosErrorMessage});


  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadEvent.status == STATUS_DOWNLOAD_ERROR) {
      if (isPlatformIos()) {
        Fluttertoast.showToast(
            msg: iosErrorMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
      onError!(downloadEvent.url!);
    }
    else
    if (downloadEvent.status == STATUS_DOWNLOAD_REMOVED) {
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
}
