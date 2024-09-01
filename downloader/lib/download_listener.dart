import 'download_event.dart';
import 'download_status_constants.dart';

class DownloadListener {
  final Function(String url, int progress) onProgress;

  final Function(String url) onComplete;

  final Function(String url) onError;

  DownloadListener(
      {required this.onProgress,
      required this.onComplete,
      required this.onError,
      });

  publishDownloadResult(DownloadEvent downloadEvent) {
    if (downloadEvent.status == STATUS_DOWNLOAD_PROGRESS) {
      onProgress(downloadEvent.url, downloadEvent.progress!);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_COMPLETED) {
      onComplete(downloadEvent.url);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_ERROR) {
      onError(downloadEvent.url);
    } else if (downloadEvent.status == STATUS_DOWNLOAD_FOREGROUND_EXCEPTION) {
      onError(downloadEvent.url);
    }
  }
}
