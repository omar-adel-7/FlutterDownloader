abstract class DownloadStates {
  const DownloadStates();
}

class InitialState extends DownloadStates {}

final class LoadingState extends DownloadStates {}

final class FileNotDownloadState extends DownloadStates {}

final class FileDownloadedState extends DownloadStates {
  final String path;
  const FileDownloadedState(this.path);
}



