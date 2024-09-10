
class DownloadListener {


  final Function({String? id,required String url,required int progress}) onProgress;

  final Function({String? id,required String url}) onComplete;

  final Function({String? id,required String url,String? error}) onError;

  DownloadListener(
      {required this.onProgress,
      required this.onComplete,
      required this.onError,
      });
}
