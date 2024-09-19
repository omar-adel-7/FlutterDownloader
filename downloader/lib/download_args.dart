
import 'package:path/path.dart';

class DownloadArgs {

  final String? id;
  final String downloadLink;
  final String destinationDirPath;
  final String fileName;
  final String androidNotificationTitle;
  final String androidNotificationProgressMessage;
  final   String androidNotificationCompleteMessage;
  void Function(String)? onDownloaded;
  void Function()? onDeleted;

  String get idToUse => id??downloadLink;
  String get filePath => join(destinationDirPath,fileName);

  DownloadArgs({
    this.id,
    required this.downloadLink,
    required this.destinationDirPath,
    required this.fileName,
    required this.androidNotificationTitle,
    required this.androidNotificationProgressMessage,
    required this.androidNotificationCompleteMessage,
    this.onDownloaded,
    this.onDeleted,
  });
}
