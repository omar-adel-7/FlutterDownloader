import 'download_status_constants.dart';

class DownloadEvent {

  DownloadEvent(
      {
        this.url,
        this.status = STATUS_NOT_DOWNLOADED,
        this.progress=0,
        this.error
      });

  String? url;
  String? status ;
  int progress;
  String? error ;
}
