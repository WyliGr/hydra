package com.wyligr.hydra

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.content.Intent

class HydraWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val PREF_PREFIX = "flutter."

        const val ACTION_ADD_WATER = "com.wyligr.hydra.ADD_WATER"
        private const val ADD_AMOUNT = 250
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_ADD_WATER) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val current = prefs.getInt("${PREF_PREFIX}today_ml", 0)
            prefs.edit().putInt("${PREF_PREFIX}today_ml", current + ADD_AMOUNT).apply()

            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, HydraWidgetProvider::class.java)
            )
            ids.forEach { id ->
                updateWidget(context, manager, id)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val todayMl = prefs.getInt("${PREF_PREFIX}today_ml", 0)
        val goalMl = prefs.getInt("${PREF_PREFIX}goal_ml", 2500)
        val debtMl = prefs.getInt("${PREF_PREFIX}debt_ml", 0)
        val effectiveGoal = goalMl + debtMl
        val progress = if (effectiveGoal > 0) {
            ((todayMl.toFloat() / effectiveGoal) * 100).toInt().coerceIn(0, 100)
        } else {
            0
        }

        val views = RemoteViews(context.packageName, R.layout.hydra_widget)

        views.setProgressBar(R.id.widget_progress, 100, progress, false)
        views.setTextViewText(R.id.widget_amount, "${todayMl}ml / ${effectiveGoal}ml")
        views.setTextViewText(R.id.widget_percent, "$progress%")

        val addIntent = Intent(context, HydraWidgetProvider::class.java).apply {
            action = ACTION_ADD_WATER
        }
        val pendingIntent = android.app.PendingIntent.getBroadcast(
            context,
            widgetId,
            addIntent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
