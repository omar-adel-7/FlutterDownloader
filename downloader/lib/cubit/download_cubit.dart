import 'package:flutter_bloc/flutter_bloc.dart';
import '../download_listener.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState()) {}
  publishProgress({required String url,required int progress,DownloadListener? downloadListener}) {
    emit(DownloadProgressState(url,progress));
    downloadListener?.onProgress(url,progress);
  }

  publishCompleted({required String url,DownloadListener? downloadListener}) {
    emit(DownloadCompletedState(url));
    downloadListener?.onComplete(url);
  }

  publishError({ required String url,String? error,DownloadListener? downloadListener}) {
    emit(DownloadErrorState(url, error));
    downloadListener?.onError(url,error: error);
  }
}