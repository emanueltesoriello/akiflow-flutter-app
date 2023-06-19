package com.akiflow.mobile

import android.content.Context
import android.os.Build
import java.util.*

object FirstDayOfWeekUtil {
    fun getFirstDayOfWeek(context: Context): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val locale = context.resources.configuration.locales.get(0)
            val calendar = Calendar.getInstance(locale)
            calendar.firstDayOfWeek
        } else {
            val locale = context.resources.configuration.locale
            val calendar = Calendar.getInstance(locale)
            calendar.firstDayOfWeek
        }
    }
}
