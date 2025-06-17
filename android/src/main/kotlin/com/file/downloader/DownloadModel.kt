package com.file.downloader

/**
 * Created by mohamed on 1/25/2018.
 */

class DownloadModel(url: String) {

    var url: String = ""
    var progress: Int = 0

    init {
        this.url = url
    }

     fun copy(): DownloadModel {
        val copied = DownloadModel(this.url)
        copied.progress = this.progress
        return copied
    }
}

