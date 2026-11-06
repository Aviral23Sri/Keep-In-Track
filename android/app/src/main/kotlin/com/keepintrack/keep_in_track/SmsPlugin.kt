package com.keepintrack.keep_in_track

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import android.content.Context

class SmsPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.keepintrack/sms")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val prefs = context.getSharedPreferences("kit_sms_pending", Context.MODE_PRIVATE)
        when (call.method) {
            "getSmsEnabled"      -> result.success(prefs.getBoolean("sms_detection_enabled", false))
            "setSmsEnabled"      -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                prefs.edit().putBoolean("sms_detection_enabled", enabled).apply()
                result.success(null)
            }
            "getPendingSmsList"  -> result.success(prefs.getString("sms_list", "[]"))
            "clearPendingSmsList"-> {
                prefs.edit().putString("sms_list", "[]").apply()
                result.success(null)
            }
            "removePendingSmsAt" -> {
                val idx = call.argument<Int>("index") ?: -1
                if (idx >= 0) {
                    val arr = JSONArray(prefs.getString("sms_list", "[]"))
                    val out = JSONArray()
                    for (i in 0 until arr.length()) { if (i != idx) out.put(arr.get(i)) }
                    prefs.edit().putString("sms_list", out.toString()).apply()
                }
                result.success(null)
            }
            // ── Quick-save notification (see QuickSave.kt) ──────────────────
            "setQuickSaveCatalog" -> {
                val json = call.argument<String>("json") ?: "{}"
                context.getSharedPreferences(QuickSaveNotifier.PREFS, Context.MODE_PRIVATE)
                    .edit().putString(QuickSaveNotifier.KEY_CATALOG, json).apply()
                result.success(null)
            }
            "getQuickSaved" -> {
                val qp = context.getSharedPreferences(QuickSaveNotifier.PREFS, Context.MODE_PRIVATE)
                result.success(qp.getString(QuickSaveNotifier.KEY_SAVED, "[]"))
            }
            "ackQuickSaved" -> {
                // Remove only the ids Flutter has written to Hive, so a
                // transaction saved meanwhile from the notification isn't lost.
                val ids = call.argument<List<String>>("ids")?.toSet() ?: emptySet()
                val qp = context.getSharedPreferences(QuickSaveNotifier.PREFS, Context.MODE_PRIVATE)
                val arr = JSONArray(qp.getString(QuickSaveNotifier.KEY_SAVED, "[]"))
                val out = JSONArray()
                for (i in 0 until arr.length()) {
                    val o = arr.optJSONObject(i) ?: continue
                    if (o.optString("id") !in ids) out.put(o)
                }
                qp.edit().putString(QuickSaveNotifier.KEY_SAVED, out.toString()).commit()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}