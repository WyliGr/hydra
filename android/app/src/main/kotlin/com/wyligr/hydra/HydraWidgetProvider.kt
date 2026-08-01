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

        // Action for tap-to-add from widget
        const val ACTION_ADD_WATER = "com.wyligr.hydra.ADD_WATER"
        private const val ADD_AMOUNT = 250 // 25cl per tap
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
            // Add water to the shared prefs
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val current = prefs.getInt("${PREF_PREFIX}today_ml", 0)
            prefs.edit().putInt("${PREF_PREFIX}today_ml", current + ADD_AMOUNT).apply()

            // Force update all widgets
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

        // Progress bar
        views.setProgressBar(R.id.widget_progress, 100, progress, 0)

        // Amount text
        val amountText = "${formatMl(todayMl)} / ${formatMl(effectiveGoal)}"
        views.setTextViewText(R.id.widget_amount, amountText)

        // Debt indicator
        if (debtMl > 0 && todayMl < goalMl) {
            views.setTextViewText(R.id.widget_debt, "+${formatMl(debtMl)} dette")
            views.setViewVisibility(R.id.widget_debt, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_debt, android.view.View.GONE)
        }

        // Title with status
        if (progress >= 100) {
            views.setTextViewText(R.id.widget_title, "Hydra 🎉")
        } else if (debtMl > 0 && todayMl < goalMl) {
            views.setTextViewText(R.id.widget_title, "Hydra ⚡")
        }

        // Tap to add water
        val addIntent = Intent(context, HydraWidgetProvider::class.java).apply {
            action = ACTION_ADD_WATER
        }
        val pendingIntent = android.app.PendingIntent.getBroadcast(
            context,
            0,
            addIntent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_progress, pendingIntent)
        views.setOnClickPendingIntent(R.id.widget_amount, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun formatMl(ml: Int): String {
        return if (ml >= 1000) {
            val l = ml / 1000.0
            if (l == l.toInt().toDouble()) "${l.toInt()}L"
            else String.format("%.1fL", l)
        } else {
            "${ml}ml"
        }
    }
}