package com.file.downloader.download

import android.content.Context
import android.os.Bundle
import android.os.StatFs
import com.file.downloader.download.IDownloadService.Companion.STATUS_DOWNLOAD_ADDED
import com.file.downloader.download.IDownloadService.Companion.STATUS_DOWNLOAD_COMPLETED
import com.file.downloader.download.IDownloadService.Companion.STATUS_DOWNLOAD_ERROR
import com.file.downloader.download.IDownloadService.Companion.STATUS_NOT_DOWNLOADED
import com.file.downloader.download.model_download.dao.DownloadDbUtil
import com.file.downloader.download.model_download.entity.DownloadModel
import java.io.File

object IDownload {
    const val SRC_URL_KEY = "src_url"
    const val SRC_DEST_DIR_PATH_KEY = "src_dest_dir_path"
    const val SRC_FILE_NAME_WITHOUT_EXTENSION_KEY = "src_file_name_without_extension"
    const val SRC_FILE_EXTENSION_KEY = "src_file_extension"
    const val SRC_NOTIFICATION_MESSAGE = "src_notification_message"
    const val SRC_NOTIFICATION_PROGRESS_MESSAGE = "src_notification_progress_message"
    const val SRC_NOTIFICATION_COMPLETE_MESSAGE = "src_notification_complete_message"
    const val SRC_ERROR_MESSAGE = "src_error_message"
    const val RESPONSE_URL_KEY = "response_url"
    const val RESPONSE_PROGRESS_KEY = "response_progress"
    const val RESPONSE_SIZE_KEY = "response_size"
    const val RESPONSE_ADDED_KEY = "response_added_key"
    const val RESPONSE_SUCCESS_ERROR_KEY = "response_success_error"
    const val RESPONSE_ERROR_MESSAGE_KEY = "response_error_message"
    const val RESPONSE_NO_FREE_SPACE_MESSAGE = "response_no_free_space"
    const val RESPONSE_CONNECTION_ERROR_MESSAGE = "response_connection_error"
    const val RESPONSE_CREATE_FOLDER_ERROR_MESSAGE = "response_create_folder_error"
    const val ResultReceiver_Key = "result_receiver"
    const val ResultReceiver_Status = "result_receiver_status"

    fun getDownloads(context: Context?): List<DownloadModel>? {
        return DownloadDbUtil.getDownloads(context)
    }

    fun getDownloadEvent(context: Context?, extras: Bundle): DownloadEvent {
        val downloadEvent = DownloadEvent()
        if (extras.containsKey(RESPONSE_URL_KEY)) {
            downloadEvent.url = extras.getString(RESPONSE_URL_KEY)
            if (extras.containsKey(RESPONSE_ADDED_KEY)) {
                downloadEvent.status = STATUS_DOWNLOAD_ADDED
            } else if (extras.containsKey(IDownloadService.RESPONSE_REMOVED_KEY)) {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_REMOVED
            }  else if (extras.containsKey(IDownloadService.RESPONSE_CANCEL_KEY)) {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_CANCELLED
            } else if (extras.containsKey(RESPONSE_PROGRESS_KEY)) {
                val progress = extras.getInt(RESPONSE_PROGRESS_KEY, 0)
                    downloadEvent.status = progress.toString() + ""
                     if (Integer.valueOf(downloadEvent.status) >= 100) {
                        downloadEvent.status = STATUS_DOWNLOAD_COMPLETED
                    }
            } else if (extras.containsKey(RESPONSE_SUCCESS_ERROR_KEY)) {
                if (extras.getBoolean(RESPONSE_SUCCESS_ERROR_KEY, false)) {
                    downloadEvent.status = STATUS_DOWNLOAD_COMPLETED
                } else {
                    downloadEvent.status = STATUS_DOWNLOAD_ERROR
                }
            }
            else if (extras.containsKey(IDownloadService.RESPONSE_FOREGROUND_EXCEPTION_KEY)) {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_FOREGROUND_EXCEPTION
            }
            else if (isInDownloading(context, downloadEvent.url)) {
                downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_QUEUED
            }
        } else if (extras.containsKey(IDownloadService.RESPONSE_ALL_REMOVED_KEY)) {
            downloadEvent.status = IDownloadService.STATUS_DOWNLOAD_ALL_REMOVED
        }
        return downloadEvent
    }

    fun isInDownloading(context: Context?, url: String?): Boolean {
        return DownloadDbUtil.isInDownloads(context, url)
    }


    fun isDownloadCompleted(context: Context?, downloadEvent: DownloadEvent?): Boolean {
        val downloadStatus = downloadEvent?.status
        return isDownloadCompleted(downloadStatus)
    }

    fun isDownloadCompleted(downloadStatus: String?): Boolean {
        if (isNumber(downloadStatus)) {
            return Integer.valueOf(downloadStatus) >= 100
        } else if (downloadStatus == STATUS_DOWNLOAD_COMPLETED) {
            return true
        }
        return false
    }


    fun isNumber(text: String?): Boolean {
        try {
            if (text != null) {
                Integer.valueOf(text)
                return true
            }
            return false
        } catch (e: Exception) {
            return false
        }
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
        var status: String? = STATUS_NOT_DOWNLOADED
        constructor() {
        }
        constructor(url: String?, status: String?) {
            this.url = url
            this.status = status
        }
    }
}