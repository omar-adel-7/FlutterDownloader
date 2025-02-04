class DownloadModel {
  final String url;
  final String iosDestinationPath;
  final String iosFileName;
  int progress;
  String iosNotificationMessage = '';
  String? iosNotificationProgressMessage;
  String? iosNotificationCompleteMessage;

  DownloadModel({
    this.url = "",
    this.iosDestinationPath = "",
    this.iosFileName = "",
    this.progress = 0,
    String? iosNotificationMessage,
    this.iosNotificationProgressMessage,
    this.iosNotificationCompleteMessage,
  }) {
    this.iosNotificationMessage = iosNotificationMessage ?? iosFileName;
  }
}
