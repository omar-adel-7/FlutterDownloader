import 'package:downloader/downloader_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/download_manager.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState());

  publishGotAndroidListData(String listData) {
   DownloadManager().getAndroidList(listData);
  }

  publishAdded({required String url, String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      DownloadManager().getAndroidList(androidListData);
    }
    emit(DownloadAddedState(url));
  }

  publishProgress({required String url, required int progress , String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      DownloadManager().getAndroidList(androidListData);
    }
    else
      {
        DownloadManager().updateIosProgress(url, progress);
      }
    emit(DownloadProgressState(url, progress));
  }

  publishCanceled({required String url, String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      DownloadManager().getAndroidList(androidListData);
    }
    emit(DownloadCanceledState(url));
  }

  publishCompleted({required String url, String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      DownloadManager().getAndroidList(androidListData);
      emit(DownloadCompletedState(url));
    } else if (DownloaderPlugin.isPlatformIos()) {
      DownloadManager().iosRemoveDownload(url);
      emit(DownloadCompletedState(url));
      if (DownloaderPlugin.isSerial) {
        DownloadManager().iosCheckToDownloadNext();
      }
    }
  }

  publishError({required String url, String? error , String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      DownloadManager().getAndroidList(androidListData);
      emit(DownloadErrorState(url,error));
    } else if (DownloaderPlugin.isPlatformIos()) {
      DownloadManager().iosRemoveDownload(url);
      emit(DownloadErrorState(url,error));
      if (DownloaderPlugin.isSerial) {
        DownloadManager().iosCheckToDownloadNext();
      }
    }
  }

  publishFileDeleted(String url) {
    emit(DownloadFileDeletedState(url));
  }
}
