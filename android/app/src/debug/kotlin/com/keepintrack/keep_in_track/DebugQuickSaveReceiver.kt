package com.keepintrack.keep_in_track

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * DEBUG BUILDS ONLY. Shows the quick-save notification without a real SMS:
 *
 *   adb shell am broadcast -a com.keepintrack.DEBUG_QUICK_SAVE \
 *     -n com.keepintrack.keep_in_track/.DebugQuickSaveReceiver \
 *     --es amount 250 --es body "paid to swiggy via UPI"
 */
class DebugQuickSaveReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val amount = intent.getStringExtra("amount")?.toDoubleOrNull() ?: 250.0
        val type   = intent.getStringExtra("type") ?: "expense"
        val body   = intent.getStringExtra("body") ?: "Rs.$amount debited via UPI"
        val id     = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
        val shown  = QuickSaveNotifier.show(
            context, id, amount, type, "upi", System.currentTimeMillis(), body
        )
        android.util.Log.i("KitQuickSave", "debug show id=$id shown=$shown")
    }
}
