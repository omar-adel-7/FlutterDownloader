import 'package:flutter_bloc/flutter_bloc.dart';
import 'download_result_state.dart';


class DownloadResultCubit extends Cubit<DownloadResultStates> {
  static DownloadResultCubit get(context) => BlocProvider.of(context);

  DownloadResultCubit() : super(DownloadInitialState()) {}
  publishProgress({required String url,required int progress}) {
    print(
        "plugin DownloadResultCubit publishProgress url=$url and progress = $progress");
    emit(DownloadProgressState(url,progress));
  }

  publishCompleted({required String url}) {
    print(
        "plugin DownloadResultCubit publishCompleted url=$url");
    emit(DownloadCompletedState(url));
  }

  publishError({ required String url,String? error}) {
    print(
        "plugin DownloadResultCubit publishError url=$url and error=$error");
    emit(DownloadErrorState(url, error));
  }
}