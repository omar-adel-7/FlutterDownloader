package com.file.downloader.download.model_download.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.file.downloader.download.model_download.dao.DownloadDbDao
import com.file.downloader.download.model_download.database.DownloadDb.Companion.DownloadDatabaseVersion
import com.file.downloader.download.model_download.entity.DownloadModel

@Database(
    entities = [DownloadModel::class], version = DownloadDatabaseVersion, exportSchema = false
)
abstract class DownloadDb : RoomDatabase() {

    abstract fun myDao(): DownloadDbDao

    companion object {
        var INSTANCE: DownloadDb? = null

        fun getDataBase(context: Context?): DownloadDb? {
            if (INSTANCE == null && context!=null) {
                synchronized(DownloadDb::class) {
                    INSTANCE = Room.databaseBuilder(
                        context.applicationContext, DownloadDb::class.java,
                        DownloadDatabaseName + SQLITE_DB_EXTENSION
                    )
                        .allowMainThreadQueries()
                        .fallbackToDestructiveMigration()
                        .build()
                }
            }
            return INSTANCE
        }

        fun destroyDataBase() {
            if (INSTANCE?.isOpen == true) {
                INSTANCE?.close()
            }
            INSTANCE = null
        }

        const val DownloadDatabaseName = "download_database"
        const val DownloadDatabaseVersion = 3
        var SQLITE_DB_EXTENSION = ".db"

    }
}
