class DownloadModel {
  final String url;
  final String destinationPath;
  final String fileName;
  int progress;

  DownloadModel(
      {this.url = "",
      this.destinationPath = "",
      this.fileName = "",
      this.progress = 0});
}
