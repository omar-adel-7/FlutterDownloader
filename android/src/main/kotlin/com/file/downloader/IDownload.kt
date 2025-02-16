package com.file.downloader

import android.content.Context
import android.os.Bundle
import android.os.StatFs
import java.io.File

object IDownload {
    const val SRC_URL_KEY = "src_url"
    const val SRC_DEST_DIR_PATH_KEY = "src_dest_dir_path"
    const val SRC_FILE_NAME_KEY = "src_file_name"
    const val SRC_NOTIFICATION_MESSAGE = "src_notification_message"
    const val SRC_NOTIFICATION_PROGRESS_MESSAGE = "src_notification_progress_message"
    const val SRC_NOTIFICATION_COMPLETE_MESSAGE = "src_notification_complete_message"
    const val RESPONSE_URL_KEY = "response_url"
    const val RESPONSE_ADDED_KEY = "response_added"
    const val RESPONSE_PROGRESS_KEY = "response_progress"
    const val RESPONSE_CANCELED_KEY = "response_canceled"
    const val RESPONSE_SUCCESS_ERROR_KEY = "response_success_error"
    const val RESPONSE_ERROR_MESSAGE_KEY = "response_error_message"
    const val RESPONSE_NO_FREE_SPACE_MESSAGE = "response_no_free_space"
    const val RESPONSE_CONNECTION_ERROR_MESSAGE = "response_connection_error"
    const val RESPONSE_CREATE_FOLDER_ERROR_MESSAGE = "response_create_folder_error"
    const val ResultReceiver_Key = "result_receiver"
    const val ResultReceiver_Url = "result_receiver_url"
    const val ResultReceiver_Status = "result_receiver_status"
    const val ResultReceiver_Progress = "result_receiver_progress"
    const val ResultReceiver_Error = "result_receiver_error"

    fun getDownloadEvent(context: Context?, extras: Bundle): DownloadEvent {
        val downloadEvent = DownloadEvent()
        downloadEvent.url = extras.getString(RESPONSE_URL_KEY)
         if (extras.containsKey(RESPONSE_ADDED_KEY)) {
            downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_ADDED
        }
        else if (extras.containsKey(RESPONSE_PROGRESS_KEY)) {
            downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_PROGRESS
            downloadEvent.progress = extras.getInt(RESPONSE_PROGRESS_KEY, 0)
        } else if (extras.containsKey(RESPONSE_SUCCESS_ERROR_KEY)) {
            if (extras.getBoolean(RESPONSE_SUCCESS_ERROR_KEY, false)) {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_COMPLETED
            } else {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_ERROR
                if (extras.containsKey(RESPONSE_ERROR_MESSAGE_KEY)) {
                    downloadEvent.error = extras.getString(RESPONSE_ERROR_MESSAGE_KEY)
                }
            }
        } else if (extras.containsKey(RESPONSE_CANCELED_KEY)) {
            downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_CANCELED
        }
        return downloadEvent
    }

    fun DeleteRecursive(context: Context?, path: String?) {
        try {
            val fileOrDirectory = path?.let { File(it) }
            if (fileOrDirectory?.exists() == true) {
                if (fileOrDirectory.isDirectory) for (child in fileOrDirectory.listFiles()!!) DeleteRecursive(
                    context,
                    child.absolutePath
                )
                fileOrDirectory.delete()
            }
        } catch (e: Exception) {
        }
    }

    fun getFolderPathOfFile(filePath: String): String {
        return filePath.substring(0, filePath.lastIndexOf(File.separator))
    }

    fun createFolderIfNotExists(folderPath: String?): Boolean {
        val folder = File(folderPath)
        return if (!folder.exists()) {
            folder.mkdirs()
        } else {
            true
        }
    }

    fun getAvailableStorageInBytes(f: File): Long {
        val stat = StatFs(f.path)
        return stat.blockSizeLong * stat.availableBlocksLong
    }

    fun isFileExist(path: String?): Boolean {
        val file = File(path)
        return file.exists()
    }

    class DownloadEvent {
        var url: String? = null
        var status: String? = null
        var progress: Int? = null
        var error: String? = null

        constructor() {
        }

        constructor(url: String?, status: String?, progress: Int?, error: String?) {
            this.url = url
            this.status = status
            this.progress = progress
            this.error = error
        }
    }
}