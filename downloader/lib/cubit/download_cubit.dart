import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../download_args.dart';
import '../download_listener.dart';
import '../downloader_plugin.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  File? _file;
  final DownloadArgs args;

  DownloadCubit(this.args) : super(InitialState()) {
    print("plugin DownloadCubit Initial getFile");
    getFile();
  }

  void getFile() async {
    final isDownloaded = DownloaderPlugin.isFileDownloaded(
      destinationDirPath: args.destinationDirPath,
      fileNameWithoutExtension: args.fileNameWithoutExtension,
      extension: args.extension,
    );
    if (isDownloaded) {
      _file = File(args.filePath);
      if (!isClosed) {
        emit(FileDownloadedState(_file!.path));
      }
    } else {
      if (!isClosed) {
        emit(FileNotDownloadState());
      }
    }
  }

  void downloadFile() async {
    if (!isClosed) {
      emit(LoadingState());
    }
    DownloaderPlugin.downloadFile(
      url: args.downloadLink,
      destinationDirPath: args.destinationDirPath,
      extension: args.extension,
      fileNameWithoutExtension: args.fileNameWithoutExtension,
      androidNotificationMessage: args.androidNotificationTitle,
      androidNotificationProgressMessage:
          args.androidNotificationProgressMessage,
      androidNotificationCompleteMessage:
          args.androidNotificationCompleteMessage,
      downloadListener:
          DownloadListener(onProgress: (String url, int progress) {
        if (!isClosed) {
          emit(LoadingState());
        }
      }, onComplete: (String url) {
        print("plugin DownloadCubit downloadListener onComplete url=$url");
        getFile();
      }, onError: (String url, {String? error}) {
        print("plugin DownloadCubit downloadListener onError url=$url");
        getFile();
      }),
    );
  }

  void deleteFile() {
    _file?.deleteSync();
    getFile();
  }
}
