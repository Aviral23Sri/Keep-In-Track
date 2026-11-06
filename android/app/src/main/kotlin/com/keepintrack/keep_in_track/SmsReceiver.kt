package com.keepintrack.keep_in_track

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class SmsReceiver : BroadcastReceiver() {

    companion object {
        const val PREFS_NAME   = "kit_sms_pending"
        const val KEY_SMS_LIST = "sms_list"
        const val KEY_ENABLED  = "sms_detection_enabled"

        // Must match the channel ID created by SmsDetectorService.init() in Flutter.
        // Flutter creates this channel on first launch, so it will always exist.
        private const val NOTIF_CHANNEL_ID = "sms_detection"

        // These regexes MUST stay in sync with lib/core/services/sms_parser.dart.
        // If the native check is stricter than the Dart parser, the SMS is queued
        // without a notification and only shows up when the app is opened.
        // (UPI debit SMS often say "Sent Rs.X" / "transferred" / "Dr", which the
        // old native list did not include.)
        private val AMOUNT_REGEX = Regex(
            """(?:INR|Rs\.?|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)""",
            RegexOption.IGNORE_CASE
        )
        private val DEBIT_REGEX  = Regex(
            """\b(?:debited|debit|deducted|sent|paid|spent|used|withdrawn|charged|purchase|payment|transferred|dr\.?)\b""",
            RegexOption.IGNORE_CASE
        )
        private val CREDIT_REGEX = Regex(
            """\b(?:credited|credit|received|deposited|refund|cr\.?|cashback)\b""",
            RegexOption.IGNORE_CASE
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_ENABLED, false)) return

        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        if (parts.isEmpty()) return

        // A long SMS (most UPI debit alerts, with "Not you? Call..." footers)
        // arrives as several parts in one broadcast. Join the parts per sender
        // so the amount and the word "debited/sent" are checked together.
        data class FullSms(val sender: String, val body: StringBuilder, val ts: Long)
        val joined = LinkedHashMap<String, FullSms>()
        for (part in parts) {
            val text   = part?.messageBody ?: continue
            val sender = part.originatingAddress ?: ""
            val entry  = joined.getOrPut(sender) {
                FullSms(sender, StringBuilder(), part.timestampMillis)
            }
            entry.body.append(text)
        }

        val currentList = JSONArray(prefs.getString(KEY_SMS_LIST, "[]"))

        // Use a unique base ID per broadcast to avoid notification collisions
        var notifId = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()

        for (sms in joined.values) {
            val body = sms.body.toString()
            if (body.isBlank()) continue

            val obj = JSONObject()
            obj.put("body",      body)
            obj.put("sender",    sms.sender)
            obj.put("timestamp", sms.ts)

            // Same decision as SmsParser.parse() in Dart.
            val amountStr = AMOUNT_REGEX.find(body)?.groupValues?.getOrNull(1)?.replace(",", "")
            val amount    = amountStr?.toDoubleOrNull()
            val isDebit   = DEBIT_REGEX.containsMatchIn(body)
            val isCredit  = CREDIT_REGEX.containsMatchIn(body)

            if (amount != null && amount > 0.0 && (isDebit || isCredit)) {
                // Mark so Flutter's SmsDetectorService skips the duplicate notification.
                obj.put("notified", true)

                val type = if (isCredit && !isDebit) "income" else "expense"
                try {
                    showNativeNotification(context, amount, type, notifId++)
                } catch (e: Exception) {
                    // Notification failed (e.g. permission revoked): let Flutter retry on open.
                    obj.put("notified", false)
                }
            }

            currentList.put(obj)
        }

        // commit() instead of apply(): the process can be killed right after
        // onReceive returns when the app is in the background.
        prefs.edit().putString(KEY_SMS_LIST, currentList.toString()).commit()
    }

    // ── Native notification (no Flutter engine needed) ─────────────────────────

    private fun showNativeNotification(
        context: Context,
        amount:  Double,
        type:    String,
        notifId: Int
    ) {
        val emoji  = if (type == "expense") "💸" else "💰"
        val verb   = if (type == "expense") "Debited" else "Credited"
        val amtStr = "₹${amount.toLong()}"

        // Tapping the notification opens the app.
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }

        val pi = PendingIntent.getActivity(
            context, notifId, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, NOTIF_CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("$emoji Transaction Detected")
            .setContentText("$verb $amtStr. Tap to log.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .setContentIntent(pi)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(notifId, notification)
    }
}
