abstract class DownloadResultStates {}

class DownloadInitialState extends DownloadResultStates {}

class DownloadProgressState extends DownloadResultStates {
  final String url;
  final int progress;

  DownloadProgressState(this.url,this.progress);
}

class DownloadCompletedState extends DownloadResultStates {
  final String url;
  DownloadCompletedState(this.url);
}

class DownloadErrorState extends DownloadResultStates {
  final String url;
  final String? error;

  DownloadErrorState(this.url,this.error);
}