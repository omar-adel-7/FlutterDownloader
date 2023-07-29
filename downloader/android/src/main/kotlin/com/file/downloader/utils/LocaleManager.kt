package com.file.downloader.utils


import android.content.Context
import android.content.res.Configuration
import java.util.*

class LocaleManager {
    companion object {
        const val ARABIC_CODE = "ar"
        const val ENGLISH_CODE = "en"
        var flutter_language_code = ARABIC_CODE

        fun getLocaleString(context: Context, resId: Int): String {
            val config = Configuration(context.resources.configuration)
            val newLocale = Locale(flutter_language_code)
            config.setLocale(newLocale)
            return context.createConfigurationContext(config).getString(resId)
        }

    }
}