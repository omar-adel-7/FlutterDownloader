package com.file.downloader.utils

import java.io.File

object FileUtility {

    fun getDownloadFilePath(
        destinationDirPath :String,  fileNameWithoutExtension: String,
        extension: String
    ): String {
         return File(destinationDirPath+fileNameWithoutExtension+extension).absolutePath
     }
}