
import 'package:path/path.dart';

class DownloadArgs {

  final String downloadLink;
  final String destinationDirPath;
  final String fileName;
  final String androidNotificationMessage;
  final String androidNotificationProgressMessage;
  final   String androidNotificationCompleteMessage;
  Function? updateIsDownloaded;
  void Function(String)? onCompleted;
  void Function()? onDeleted;

  String get filePath => join(destinationDirPath,fileName);

  DownloadArgs({
    required this.downloadLink,
    required this.destinationDirPath,
    required this.fileName,
    required this.androidNotificationMessage,
    required this.androidNotificationProgressMessage,
    required this.androidNotificationCompleteMessage,
    this.onCompleted,
    this.onDeleted,
  });
}
