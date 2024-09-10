abstract class DownloadStates {
  const DownloadStates();
}

class DownloadInitialState extends DownloadStates {}

class DownloadProgressState extends DownloadStates {
  final String url;
  final int progress;

  DownloadProgressState(this.url,this.progress);
}

class DownloadCompletedState extends DownloadStates {
  final String url;
  DownloadCompletedState(this.url);
}

class DownloadErrorState extends DownloadStates {
  final String url;
  final String? error;

  DownloadErrorState(this.url,this.error);
}


