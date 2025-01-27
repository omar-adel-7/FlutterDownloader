import 'package:downloader/downloader_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/download_manager.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState());

  publishGotAndroidListData(String listData) {
    print("publishGotAndroidListData listData = $listData");
   DownloadManager().getAndroidList(listData);
  }

  publishAdded({required String url, String? androidListData})  {
    print("publishAdded");
    if (DownloaderPlugin.isPlatformAndroid()) {
      print("publishAdded android");
      DownloadManager().getAndroidList(androidListData);
    }
    emit(DownloadAddedState(url));
  }

  publishProgress({required String url, required int progress , String? androidListData})  {
    print("publishProgress");
    if (DownloaderPlugin.isPlatformAndroid()) {
      print("publishProgress android");
      DownloadManager().getAndroidList(androidListData);
    }
    else
      {
        print("publishProgress ios");
        DownloadManager().updateProgress(url, progress);
      }
    emit(DownloadProgressState(url, progress));
  }

  publishCanceled({required String url, String? androidListData})  {
    print("publishCanceled");
    if (DownloaderPlugin.isPlatformAndroid()) {
      print("publishCanceled android");
      DownloadManager().getAndroidList(androidListData);
    }
    emit(DownloadCanceledState(url));
  }

  publishCompleted({required String url, String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      if (DownloaderPlugin.isSerial) {
        print("publishCompleted android isSerial true");
      } else {
        print("publishCompleted android isSerial false");
      }
      DownloadManager().getAndroidList(androidListData);
      emit(DownloadCompletedState(url));
    } else if (DownloaderPlugin.isPlatformIos()) {
      DownloadManager().iosRemoveDownload(url);
      emit(DownloadCompletedState(url));
      if (DownloaderPlugin.isSerial) {
        print("publishCompleted ios isSerial true");
        DownloadManager().iosCheckToDownloadNext();
      } else {
        print("publishCompleted ios isSerial false");
      }
    }
  }

  publishError({required String url, String? error , String? androidListData})  {
    if (DownloaderPlugin.isPlatformAndroid()) {
      if (DownloaderPlugin.isSerial) {
        print("publishError android isSerial true");
      } else {
        print("publishError android isSerial false");
      }
      DownloadManager().getAndroidList(androidListData);
      emit(DownloadErrorState(url,error));
    } else if (DownloaderPlugin.isPlatformIos()) {
      DownloadManager().iosRemoveDownload(url);
      emit(DownloadErrorState(url,error));
      if (DownloaderPlugin.isSerial) {
        print("publishError ios isSerial true");
        DownloadManager().iosCheckToDownloadNext();
      } else {
        print("publishError ios isSerial false");
      }
    }
  }

  publishFileDeleted(String url) {
    emit(DownloadFileDeletedState(url));
  }
}
