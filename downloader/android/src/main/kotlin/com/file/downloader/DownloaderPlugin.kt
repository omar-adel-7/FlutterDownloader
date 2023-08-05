package com.file.downloader

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ResultReceiver
import androidx.annotation.NonNull
import com.file.downloader.download.IDownload

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DownloaderPlugin */
class DownloaderPlugin: FlutterPlugin, MethodCallHandler  {

  val CHANNEL_DOWNLOAD = "download"
  private val CHANNEL_DOWNLOAD_START = "startDownload"
  private val CHANNEL_DOWNLOAD_RESULT = "downloadResult"
  private val CHANNEL_DOWNLOAD_CANCEL = "cancelDownload"
  private var methodChannelDownload : MethodChannel? = null
  private var context: Context? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannelDownload = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_DOWNLOAD)
    methodChannelDownload?.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, @NonNull result: Result) {
    if (call.method.equals(CHANNEL_DOWNLOAD_START)) {
      val argsMap = call.arguments as HashMap<*, *>
      val url = argsMap["url"] as String
      val destinationDirPath = argsMap["destinationDirPath"]as String
      val fileNameWithoutExtension = argsMap["fileNameWithoutExtension"]as String
      val extension = argsMap["extension"]as String
      val notificationMessage = argsMap["notificationMessage"]as String
      val notificationProgressMessage = argsMap["notificationProgressMessage"]as String
      val notificationCompleteMessage = argsMap["notificationCompleteMessage"]as String

      context?.let {
        val intent = Intent(it, DownloadService::class.java)
        intent.action = it.getString(
          R.string.download_ACTION_DOWNLOAD_ITEM
        )
        intent.putExtra(IDownload.SRC_URL_KEY, url)
        intent.putExtra(IDownload.SRC_DEST_DIR_PATH_KEY, destinationDirPath)
        intent.putExtra(IDownload.SRC_FILE_NAME_WITHOUT_EXTENSION_KEY, fileNameWithoutExtension)
        intent.putExtra(IDownload.SRC_FILE_EXTENSION_KEY, extension)
        intent.putExtra(IDownload.SRC_NOTIFICATION_MESSAGE, notificationMessage)
        intent.putExtra(IDownload.SRC_NOTIFICATION_PROGRESS_MESSAGE, notificationProgressMessage)
        intent.putExtra(IDownload.SRC_NOTIFICATION_COMPLETE_MESSAGE, notificationCompleteMessage)
        intent.putExtra(IDownload.ResultReceiver_Key, object : ResultReceiver(Handler(Looper.getMainLooper())) {
          override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
            super.onReceiveResult(resultCode, resultData)
              val status = resultData.getString(IDownload.ResultReceiver_Status)
              val progress = resultData.getInt(IDownload.ResultReceiver_Progress)
              methodChannelDownload?.invokeMethod(
                CHANNEL_DOWNLOAD_RESULT, hashMapOf(
                  "url" to url,
                  "status" to status,
                  "progress" to progress,
                )
              )
          }
        })
        it.startService(intent)
      }
    } else if (call.method.equals(CHANNEL_DOWNLOAD_CANCEL)) {
        context?.let { DownloadService.sendCancelAll(it) }
      }
     else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = null
    methodChannelDownload?.setMethodCallHandler(null)
    methodChannelDownload = null
  }

}
