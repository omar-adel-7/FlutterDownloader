import 'package:flutter_bloc/flutter_bloc.dart';
import '../download_listener.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState()) {}
  publishProgress({String? id,required String url,required int progress,DownloadListener? downloadListener}) {
    emit(DownloadProgressState(id,url,progress));
    downloadListener?.onProgress(id:id,url:url,progress: progress);
  }

  publishCompleted({String? id,required String url,DownloadListener? downloadListener}) async {
    emit(DownloadCompletedState(id,url));
    downloadListener?.onComplete(id:id,url:url);
  }

  publishError({String? id, required String url,String? error,DownloadListener? downloadListener}) async {
    emit(DownloadErrorState(id,url, error));
    downloadListener?.onError(id:id,url:url,error: error);
  }
}


