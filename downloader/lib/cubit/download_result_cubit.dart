import 'package:flutter_bloc/flutter_bloc.dart';

import 'download_result_state.dart';

class DownloadResultCubit extends Cubit<DownloadResultStates> {
  DownloadResultCubit() : super(DownloadInitialState());

  static DownloadResultCubit get(context) => BlocProvider.of(context);

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