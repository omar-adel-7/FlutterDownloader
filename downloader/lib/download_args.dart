
import 'package:path/path.dart';

class DownloadArgs {

  final String? id;
  final String downloadLink;
  final String destinationDirPath;
  final String fileNameWithoutExtension;
  final  String extension;
  final String androidNotificationTitle;
  final String androidNotificationProgressMessage;
  final   String androidNotificationCompleteMessage;
  void Function(String)? onDownloaded;
  void Function()? onDeleted;
  String get filePath => "${join(destinationDirPath,fileNameWithoutExtension)}.$extension";

  DownloadArgs({
    this.id,
    required this.downloadLink,
    required this.destinationDirPath,
    required this.fileNameWithoutExtension,
    required this.extension,
    required this.androidNotificationTitle,
    required this.androidNotificationProgressMessage,
    required this.androidNotificationCompleteMessage,
    this.onDownloaded,
    this.onDeleted,
  });
}
