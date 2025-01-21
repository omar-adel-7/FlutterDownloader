import 'package:path/path.dart';

class DownloadModel {

  String url;
  final String destinationPath;
  final String fileName;
  final String androidNotificationMessage;
  final String androidNotificationProgressMessage;
  final String androidNotificationCompleteMessage;
  int progress;
  String get filePath => join(destinationPath,fileName);


  DownloadModel({
    required this.url,
    required this.destinationPath,
    required this.fileName,
    required this.androidNotificationMessage,
    required this.androidNotificationProgressMessage,
    required this.androidNotificationCompleteMessage,
    this.progress = 0
  });

}



