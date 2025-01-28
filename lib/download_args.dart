
import 'package:path/path.dart';

class DownloadArgs {

  final String downloadLink;
  final String destinationDirPath;
  final String fileName;
  String androidNotificationMessage = '';
  Function? updateIsDownloaded;
  void Function(String)? onCompleted;
  void Function()? onDeleted;

  String get filePath => join(destinationDirPath,fileName);

  DownloadArgs({
    required this.downloadLink,
    required this.destinationDirPath,
    required this.fileName,
    String? androidNotificationMessage,
    this.updateIsDownloaded,
    this.onCompleted,
    this.onDeleted,
  }){
    this.androidNotificationMessage = androidNotificationMessage ?? fileName;
  }
}
