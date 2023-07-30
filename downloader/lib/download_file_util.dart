import 'dart:io';
import 'package:path/path.dart';


 bool isFileExist(
{required String destinationDirPath, required String fileName})  {
String path = getFilePath(
    destinationDirPath: destinationDirPath, fileName: fileName);
return File(path).existsSync();
}

String getFilePath(
    {required String destinationDirPath, required String fileName})  {
  return join(destinationDirPath, fileName);
}