import 'package:fluttertoast/fluttertoast.dart';

import 'download_event.dart';
import 'download_status_constants.dart';

class DownloadListener {
  final Function(String url, int progress) onProgress;

  final Function(String url) onComplete;

  final Function(String url) onError;

  final String errorMessage;

  DownloadListener(
      {required this.onProgress,
      required this.onComplete,
      required this.onError,
      required this.errorMessage});

  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadEvent.status == STATUS_DOWNLOAD_PROGRESS) {
      onProgress(downloadEvent.url, downloadEvent.progress!);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_COMPLETED) {
      onComplete(downloadEvent.url);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_ERROR) {
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      onError(downloadEvent.url);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_FOREGROUND_EXCEPTION) {
      onError(downloadEvent.url);
    }
  }
}
