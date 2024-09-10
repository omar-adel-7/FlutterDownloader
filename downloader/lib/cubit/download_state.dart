abstract class DownloadStates {
  const DownloadStates();
}

class DownloadInitialState extends DownloadStates {}

class DownloadProgressState extends DownloadStates {
  final String? id;
  final String url;
  final int progress;

  DownloadProgressState(this.id,this.url,this.progress);
}

class DownloadCompletedState extends DownloadStates {
  final String? id;
  final String url;
  DownloadCompletedState(this.id,this.url);
}

class DownloadErrorState extends DownloadStates {
  final String? id;
  final String url;
  final String? error;

  DownloadErrorState(this.id,this.url,this.error);
}


