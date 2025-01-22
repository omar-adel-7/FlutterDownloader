import 'package:downloader/downloader_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/download_manager.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState());

  publishStarted({required String url}) {
    emit(DownloadStartedState(url));
  }

  publishProgress({required String url, required int progress}) {
    emit(DownloadProgressState(url, progress));
      DownloadManager().updateProgress(url, progress);
  }

  publishCompleted({required String url}) async {
    emit(DownloadCompletedState(url));
      if (DownloaderPlugin.isSerial) {
        DownloadManager().removeAndDownloadNext(url);
      } else {
        DownloadManager().removeDownload(url);
      }
  }

  publishError({required String url, String? error}) async {
    emit(DownloadErrorState(url, error));
      if (DownloaderPlugin.isSerial) {
        DownloadManager().removeAndDownloadNext(url);
      } else {
        DownloadManager().removeDownload(url);
      }
  }
}
