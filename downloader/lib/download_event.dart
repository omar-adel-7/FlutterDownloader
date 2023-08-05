class DownloadEvent {

  DownloadEvent(
      {
        required this.url,
        required this.status,
        this.progress,
        this.error,
      });

  String url;
  String status ;
  int? progress;
  String? error ;
}
