import 'package:flutter_bloc/flutter_bloc.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadStates> {
  static DownloadCubit get(context) => BlocProvider.of(context);

  DownloadCubit() : super(DownloadInitialState()) {}
  publishProgress({required String url,required int progress}) {
    emit(DownloadProgressState(url,progress));
  }

  publishCompleted({required String url}) {
    emit(DownloadCompletedState(url));
  }

  publishError({ required String url,String? error}) {
    emit(DownloadErrorState(url, error));
  }
}