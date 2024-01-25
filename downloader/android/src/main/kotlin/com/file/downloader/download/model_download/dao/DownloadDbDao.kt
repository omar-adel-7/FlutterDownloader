package com.file.downloader.download.model_download.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.file.downloader.download.model_download.entity.DownloadModel

@Dao
interface DownloadDbDao {
    @Query("SELECT * FROM DownloadModel")
    fun getDownloads(): List<DownloadModel>

    @Insert
    fun insertDownload(downloadModel: DownloadModel)

    @Query("DELETE FROM DownloadModel  where url=:url")
    fun removeDownload(url: String?)

    @Query("DELETE FROM DownloadModel")
    fun clearDownloads()

    @Query("SELECT * FROM DownloadModel where  url=:url  ")
    fun isInDownloads(url: String?): DownloadModel?
}