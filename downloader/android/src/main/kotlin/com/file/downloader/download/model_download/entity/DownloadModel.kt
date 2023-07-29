package com.file.downloader.download.model_download.entity

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity
class DownloadModel
    (
    @PrimaryKey
    val url: String,
    val dest_dir_path: String,
    val file_name_without_extension: String,
    val extension : String,
    val service_type: String,
    val notification_message: String? = null,
    val notification_progress_message: String? = null,
    val notification_complete_message: String? = null,
    val error_message: String? = null,

    ): Parcelable {
    val dest_file_full_path: String
        get(
        ) = dest_dir_path + file_name_without_extension + extension
    val temp_dest_file_full_path: String
        get(
        ) = dest_dir_path + file_name_without_extension +"-temp"+ extension
}