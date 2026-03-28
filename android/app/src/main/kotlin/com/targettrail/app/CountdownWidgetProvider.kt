package com.targettrail.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class CountdownWidgetProvider : HomeWidgetProvider() {
    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        val prefs =
            context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                .edit()
        appWidgetIds.forEach { widgetId ->
            prefs.remove(selectionKey(widgetId))
        }
        prefs.apply()
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val countdownsJson =
            widgetData.getString("countdown_widget_countdowns_json", "[]") ?: "[]"
        val countdowns = JSONArray(countdownsJson)
        appWidgetIds.forEach { widgetId ->
            val selectedId = widgetData.getString(selectionKey(widgetId), null)
            val item = findItem(countdowns, selectedId)
                ?: if (countdowns.length() > 0) countdowns.getJSONObject(0) else null

            val views = RemoteViews(context.packageName, R.layout.countdown_widget)
                .apply {
                    setTextViewText(
                        R.id.widget_title,
                        item?.optString("title")
                            ?: widgetData.getString(
                                "countdown_widget_title",
                                "No active countdown"
                            )
                    )
                    setTextViewText(
                        R.id.widget_days,
                        item?.opt("days")?.toString()
                            ?: widgetData.getString("countdown_widget_days", "--")
                    )
                    setTextViewText(
                        R.id.widget_subtitle,
                        item?.optString("subtitle")
                            ?: widgetData.getString(
                                "countdown_widget_subtitle",
                                "Create a countdown to see it here"
                            )
                    )
                }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun findItem(items: JSONArray, selectedId: String?) =
        (0 until items.length())
            .map { items.getJSONObject(it) }
            .firstOrNull { item ->
                selectedId != null && item.optString("id") == selectedId
            }

    companion object {
        fun selectionKey(widgetId: Int) = "countdown_widget_selection_$widgetId"

        fun updateWidget(context: Context, appWidgetId: Int) {
            val manager = AppWidgetManager.getInstance(context)
            val provider = ComponentName(context, CountdownWidgetProvider::class.java)
            val views = RemoteViews(context.packageName, R.layout.countdown_widget)
            manager.updateAppWidget(appWidgetId, views)
            val intent = Intent(context, CountdownWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_IDS,
                    intArrayOf(appWidgetId)
                )
            }
            context.sendBroadcast(intent)
            manager.notifyAppWidgetViewDataChanged(
                intArrayOf(appWidgetId),
                R.id.widget_root
            )
        }
    }
}
