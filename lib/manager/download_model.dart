import 'package:path/path.dart';

class DownloadModel {

  String url;
  final String destinationPath;
  final String fileName;
  final String notificationMessage;
  final String notificationProgressMessage;
  final String notificationCompleteMessage;
  int progress;
  String get filePath => join(destinationPath,fileName);


  DownloadModel({
    required this.url,
    required this.destinationPath,
    required this.fileName,
    required this.notificationMessage,
    required this.notificationProgressMessage,
    required this.notificationCompleteMessage,
    this.progress = 0
  });

}



