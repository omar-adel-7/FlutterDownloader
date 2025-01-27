abstract class DownloadStates {
  const DownloadStates();
}

class DownloadInitialState extends DownloadStates {}

class DownloadAddedState extends DownloadStates {
  final String url;
  DownloadAddedState(this.url);
}

class DownloadProgressState extends DownloadStates {
  final String url;
  final int progress;

  DownloadProgressState(this.url,this.progress);
}

class DownloadCanceledState extends DownloadStates {
  final String url;
  DownloadCanceledState(this.url);
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

class DownloadFileDeletedState extends DownloadStates {
  final String url;

  DownloadFileDeletedState(this.url);
}


