import 'package:flutter_bloc/flutter_bloc.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState()) {}
  publishProgress({String? id,required String url,required int progress}) {
    emit(DownloadProgressState(id,url,progress));
  }

  publishCompleted({String? id,required String url}) async {
    emit(DownloadCompletedState(id,url));
  }

  publishError({String? id, required String url,String? error}) async {
    emit(DownloadErrorState(id,url, error));
  }
}


