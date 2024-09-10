
class DownloadListener {
  final Function(String url, int progress) onProgress;

  final Function(String url) onComplete;

  final Function(String url,{String? error}) onError;

  DownloadListener(
      {required this.onProgress,
      required this.onComplete,
      required this.onError,
      });

}
