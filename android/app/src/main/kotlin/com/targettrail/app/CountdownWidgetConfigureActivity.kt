package com.targettrail.app

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class CountdownWidgetConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var prefs: android.content.SharedPreferences
    private lateinit var items: JSONArray
    private var selectedId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        setContentView(R.layout.countdown_widget_settings)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        items = JSONArray(
            prefs.getString("countdown_widget_countdowns_json", "[]") ?: "[]"
        )
        selectedId = prefs.getString(
            CountdownWidgetProvider.selectionKey(appWidgetId),
            null
        ) ?: if (items.length() > 0) items.getJSONObject(0).optString("id") else null

        bindTargets()
        renderPreview()

        findViewById<Button>(R.id.widget_settings_cancel).setOnClickListener {
            finish()
        }

        findViewById<Button>(R.id.widget_settings_save).setOnClickListener {
            if (selectedId != null) {
                prefs.edit()
                    .putString(
                        CountdownWidgetProvider.selectionKey(appWidgetId),
                        selectedId
                    )
                    .apply()
                CountdownWidgetProvider.updateWidget(this, appWidgetId)
            }

            val result = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, result)
            finish()
        }
    }

    private fun bindTargets() {
        val container = findViewById<LinearLayout>(R.id.widget_target_options)
        val emptyView = findViewById<TextView>(R.id.widget_target_empty)
        container.removeAllViews()

        if (items.length() == 0) {
            emptyView.visibility = View.VISIBLE
            return
        }

        emptyView.visibility = View.GONE

        for (index in 0 until items.length()) {
            val item = items.getJSONObject(index)
            val optionView = layoutInflater.inflate(
                R.layout.countdown_widget_target_option,
                container,
                false
            )

            val radio = optionView.findViewById<RadioButton>(R.id.widget_option_radio)
            val title = optionView.findViewById<TextView>(R.id.widget_option_title)
            val subtitle = optionView.findViewById<TextView>(R.id.widget_option_subtitle)

            val optionId = item.optString("id")
            radio.isChecked = optionId == selectedId
            title.text = item.optString("title")
            subtitle.text = item.optString("subtitle")

            optionView.setOnClickListener {
                selectedId = optionId
                bindTargets()
                renderPreview()
            }

            container.addView(optionView)
        }
    }

    private fun renderPreview() {
        val item = findSelectedItem()
        val titleView = findViewById<TextView>(R.id.widget_preview_title)
        val daysView = findViewById<TextView>(R.id.widget_preview_days)
        val subtitleView = findViewById<TextView>(R.id.widget_preview_subtitle)

        titleView.text = item?.optString("title") ?: "No active countdown"
        daysView.text = item?.opt("days")?.toString() ?: "--"
        subtitleView.text = item?.optString("subtitle")
            ?: "Create a countdown to see it here"
    }

    private fun findSelectedItem(): JSONObject? {
        for (index in 0 until items.length()) {
            val item = items.getJSONObject(index)
            if (item.optString("id") == selectedId) {
                return item
            }
        }
        return if (items.length() > 0) items.getJSONObject(0) else null
    }
}
