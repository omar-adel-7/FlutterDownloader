package com.file.downloader.download.model_download.dao

import android.content.Context
import com.file.downloader.download.model_download.database.DownloadDb
import com.file.downloader.download.model_download.entity.DownloadModel


object DownloadDbUtil {
    fun getDownloads(context: Context?, service_type: String?): List<DownloadModel>? {
        return DownloadDb.getDataBase(context)?.myDao()?.getDownloads(service_type)
    }

    fun insertDownload(context: Context?, downloadModel: DownloadModel?) {
        DownloadDb.getDataBase(context)?.myDao()?.insertDownload(downloadModel)
    }

    fun removeDownload(context: Context?, url: String?) {
        DownloadDb.getDataBase(context)?.myDao()?.removeDownload(url)
    }

    fun clearDownloads(context: Context?, service_type: String?) {
        DownloadDb.getDataBase(context)?.myDao()?.clearDownloads(service_type)
    }

    fun isInDownloads(context: Context?, url: String?): Boolean {
        return DownloadDb.getDataBase(context)?.myDao()?.isInDownloads(url) != null
    }
}