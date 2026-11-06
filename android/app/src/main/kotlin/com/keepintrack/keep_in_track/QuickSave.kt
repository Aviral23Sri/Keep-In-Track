package com.keepintrack.keep_in_track

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.RemoteInput
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/**
 * Quick-save transaction notification.
 *
 * Android notifications can't show dropdowns or run multi-step forms, so the
 * expanded notification is a custom RemoteViews body with a 3x3 grid of chips.
 * Every tap goes to [QuickSaveReceiver], which updates a small state object and
 * re-posts the SAME notification in place:
 *
 *   step "cat"  → pick a category (paged 9 at a time with "More")
 *   step "sub"  → pick a subcategory (optional), then "Save"
 *   step "done" → "Saved" confirmation that dismisses itself
 *
 * The app's data lives in Hive (Dart-only), so Save writes the transaction to a
 * native queue ([KEY_SAVED]); Flutter moves it into Hive on the next launch/resume
 * (see lib/core/services/quick_save_service.dart). Categories, subcategories and
 * merchant hints are pushed the other way by Flutter into [KEY_CATALOG].
 */
object QuickSaveNotifier {

    const val PREFS       = "kit_quick_save"
    const val KEY_CATALOG = "catalog"      // written by Flutter
    const val KEY_SAVED   = "saved_txns"   // read + cleared by Flutter
    const val KEY_TITLE_INPUT = "kit_title"
    private const val STATE_PREFIX = "state_"

    const val CHANNEL_ID = "sms_detection"   // same channel Flutter creates
    private const val PAGE_SIZE = 9
    private const val DONE_TIMEOUT_MS = 6000L

    private val CHIP_IDS = intArrayOf(
        R.id.chip_0, R.id.chip_1, R.id.chip_2,
        R.id.chip_3, R.id.chip_4, R.id.chip_5,
        R.id.chip_6, R.id.chip_7, R.id.chip_8,
    )

    // ── Catalog (categories pushed from Flutter) ───────────────────────────────

    data class Sub(val id: String, val name: String)
    data class Cat(val id: String, val name: String, val type: String, val color: Int, val subs: List<Sub>)
    data class Hint(val keyword: String, val categoryId: String, val subcategoryId: String?)

    private fun loadCatalog(ctx: Context): Pair<List<Cat>, List<Hint>>? {
        val raw = prefs(ctx).getString(KEY_CATALOG, null) ?: return null
        return try {
            val root = JSONObject(raw)
            val cats = mutableListOf<Cat>()
            val arr = root.optJSONArray("categories") ?: JSONArray()
            for (i in 0 until arr.length()) {
                val c = arr.getJSONObject(i)
                val subsArr = c.optJSONArray("subs") ?: JSONArray()
                val subs = (0 until subsArr.length()).map {
                    val s = subsArr.getJSONObject(it)
                    Sub(s.getString("id"), s.getString("name"))
                }
                cats += Cat(
                    c.getString("id"), c.getString("name"), c.optString("type", "expense"),
                    parseColor(c.optString("color")), subs,
                )
            }
            val hints = mutableListOf<Hint>()
            val hArr = root.optJSONArray("hints") ?: JSONArray()
            for (i in 0 until hArr.length()) {
                val h = hArr.getJSONObject(i)
                hints += Hint(
                    h.getString("k"), h.getString("c"),
                    if (h.isNull("s")) null else h.optString("s").ifEmpty { null },
                )
            }
            if (cats.isEmpty()) null else cats to hints
        } catch (e: Exception) {
            null
        }
    }

    private fun parseColor(hex: String): Int = try {
        val clean = hex.removePrefix("#").removePrefix("0x")
        val argb = if (clean.length == 6) "FF$clean" else clean
        argb.toLong(16).toInt()
    } catch (e: Exception) {
        Color.GRAY
    }

    /** Categories that fit this transaction's type, suggested one first. */
    private fun categoriesFor(all: List<Cat>, state: JSONObject): List<Cat> {
        val type = state.optString("type", "expense")
        val matching = all.filter { it.type == type }.ifEmpty { all }
        val suggested = state.optString("suggestedCat")
        if (suggested.isEmpty()) return matching
        val first = matching.firstOrNull { it.id == suggested } ?: return matching
        return listOf(first) + matching.filter { it.id != suggested }
    }

    // ── Entry point from SmsReceiver ───────────────────────────────────────────

    /**
     * Shows the quick-save notification. Returns false when Flutter hasn't
     * synced any categories yet (app not opened since install/update), so the
     * caller can fall back to the plain "tap to log" notification.
     */
    fun show(
        ctx: Context, notifId: Int, amount: Double, type: String,
        paymentMode: String, smsTimestamp: Long, body: String,
    ): Boolean {
        val (cats, hints) = loadCatalog(ctx) ?: return false

        val state = JSONObject()
        state.put("notifId", notifId)
        state.put("amount", amount)
        state.put("type", type)
        state.put("paymentMode", paymentMode)
        state.put("ts", smsTimestamp)
        state.put("step", "cat")
        state.put("page", 0)

        // Merchant hint: first known merchant name that appears in the SMS text.
        val lower = body.lowercase()
        val hint = hints.firstOrNull { it.keyword.length >= 3 && lower.contains(it.keyword) }
        if (hint != null && cats.any { it.id == hint.categoryId }) {
            state.put("suggestedCat", hint.categoryId)
            hint.subcategoryId?.let { state.put("suggestedSub", it) }
            state.put("merchant", hint.keyword)
        }

        saveState(ctx, notifId, state)
        render(ctx, state, cats, alert = true)
        return true
    }

    // ── Actions from notification taps ─────────────────────────────────────────

    fun handle(ctx: Context, notifId: Int, action: String, arg: String?) {
        val state = loadState(ctx, notifId) ?: run { cancel(ctx, notifId); return }
        val cats = loadCatalog(ctx)?.first ?: run { cancel(ctx, notifId); return }

        when (action) {
            "cat" -> {
                state.put("step", "sub")
                state.put("catId", arg)
                state.put("page", 0)
                // Pre-select the merchant's usual subcategory when it fits.
                val cat = cats.firstOrNull { it.id == arg }
                val sugg = state.optString("suggestedSub")
                if (state.optString("suggestedCat") == arg && cat?.subs?.any { it.id == sugg } == true) {
                    state.put("subId", sugg)
                } else {
                    state.remove("subId")
                }
            }
            "sub" -> {
                // Tap again to un-select (save without a subcategory).
                if (state.optString("subId") == arg) state.remove("subId") else state.put("subId", arg)
            }
            "title" -> {
                // arg carries the text typed in the notification's reply field.
                val t = arg?.trim().orEmpty()
                if (t.isEmpty()) state.remove("title") else state.put("title", t.take(80))
            }
            "more" -> state.put("page", state.optInt("page", 0) + 1)
            "back" -> {
                state.put("step", "cat")
                state.put("page", 0)
                state.remove("subId")
            }
            "save" -> {
                if (state.optString("catId").isEmpty()) return
                queueTransaction(ctx, state)
                state.put("step", "done")
            }
        }

        if (state.optString("step") == "done") {
            clearState(ctx, notifId)
        } else {
            saveState(ctx, notifId, state)
        }
        render(ctx, state, cats, alert = false)
    }

    // ── Rendering ─────────────────────────────────────────────────────────────

    private fun render(ctx: Context, state: JSONObject, allCats: List<Cat>, alert: Boolean) {
        ensureChannel(ctx)
        val notifId = state.getInt("notifId")
        val type    = state.optString("type", "expense")
        val amount  = state.getDouble("amount")
        val amtStr  = "₹" + if (amount % 1.0 == 0.0) amount.toLong().toString() else String.format("%.2f", amount)
        val verb    = if (type == "expense") "Debited" else "Credited"
        val emoji   = if (type == "expense") "💸" else "💰"
        val step    = state.optString("step", "cat")

        val cats    = categoriesFor(allCats, state)
        val cat     = allCats.firstOrNull { it.id == state.optString("catId") }
        val sub     = cat?.subs?.firstOrNull { it.id == state.optString("subId") }

        val builder = NotificationCompat.Builder(ctx, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setOnlyAlertOnce(true)
            .setContentIntent(openAppIntent(ctx, notifId))
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .setPublicVersion(
                NotificationCompat.Builder(ctx, CHANNEL_ID)
                    .setSmallIcon(R.mipmap.launcher_icon)
                    .setContentTitle("Transaction detected")
                    .build()
            )
        if (alert) builder.setDefaults(NotificationCompat.DEFAULT_ALL)

        if (step == "done") {
            val path = listOfNotNull(cat?.name, sub?.name).joinToString(" › ")
            builder
                .setContentTitle("✅ Saved $amtStr")
                .setContentText(path)
                .setAutoCancel(true)
                .setTimeoutAfter(DONE_TIMEOUT_MS)
            nm(ctx).notify(notifId, builder.build())
            return
        }

        val rv = RemoteViews(ctx.packageName, R.layout.notif_quick_save)
        val page: Int
        val items: List<Pair<String, CharSequence>>   // (id, label)
        val selectedId: String?

        if (step == "cat") {
            rv.setTextViewText(R.id.step_label, "$verb $amtStr · choose a category")
            items = cats.map { it.id to dotLabel(it.name, it.color) }
            selectedId = null
            rv.setViewVisibility(R.id.btn_back, android.view.View.GONE)
            rv.setViewVisibility(R.id.btn_save, android.view.View.GONE)
        } else {
            val catName = cat?.name ?: "Category"
            rv.setTextViewText(
                R.id.step_label,
                if (cat?.subs.isNullOrEmpty()) "$amtStr · $catName" else "$amtStr · $catName › subcategory (optional)"
            )
            items = (cat?.subs ?: emptyList()).map { it.id to it.name }
            selectedId = state.optString("subId").ifEmpty { null }
            rv.setViewVisibility(R.id.btn_back, android.view.View.VISIBLE)
            rv.setViewVisibility(R.id.btn_save, android.view.View.VISIBLE)
            rv.setOnClickPendingIntent(R.id.btn_back, actionIntent(ctx, notifId, "back", null))
            rv.setOnClickPendingIntent(R.id.btn_save, actionIntent(ctx, notifId, "save", null))
            rv.setTextViewText(R.id.btn_save, "Save")
        }

        val pages = maxOf(1, (items.size + PAGE_SIZE - 1) / PAGE_SIZE)
        page = state.optInt("page", 0) % pages
        val slice = items.drop(page * PAGE_SIZE).take(PAGE_SIZE)

        if (items.isEmpty()) {
            rv.setViewVisibility(R.id.empty_label, android.view.View.VISIBLE)
            rv.setTextViewText(R.id.empty_label, "No subcategories. Tap Save to log it under ${cat?.name ?: "this category"}.")
        }

        CHIP_IDS.forEachIndexed { i, viewId ->
            val item = slice.getOrNull(i)
            if (item == null) {
                // INVISIBLE (not GONE) keeps the remaining chips the same width.
                rv.setViewVisibility(viewId, android.view.View.INVISIBLE)
            } else {
                rv.setViewVisibility(viewId, android.view.View.VISIBLE)
                rv.setTextViewText(viewId, item.second)
                if (item.first == selectedId) {
                    rv.setInt(viewId, "setBackgroundResource", R.drawable.kit_chip_selected)
                    rv.setTextColor(viewId, Color.WHITE)
                }
                rv.setOnClickPendingIntent(
                    viewId, actionIntent(ctx, notifId, if (step == "cat") "cat" else "sub", item.first)
                )
            }
        }
        // Hide fully empty rows so the notification stays compact.
        val rows = intArrayOf(R.id.row_0, R.id.row_1, R.id.row_2)
        rows.forEachIndexed { r, rowId ->
            rv.setViewVisibility(
                rowId, if (slice.size > r * 3) android.view.View.VISIBLE else android.view.View.GONE
            )
        }

        if (pages > 1) {
            rv.setViewVisibility(R.id.btn_more, android.view.View.VISIBLE)
            rv.setTextViewText(R.id.btn_more, "More ${page + 1}/$pages ›")
            rv.setOnClickPendingIntent(R.id.btn_more, actionIntent(ctx, notifId, "more", null))
        } else {
            rv.setViewVisibility(R.id.btn_more, android.view.View.GONE)
        }

        val collapsedText = when {
            step == "sub" && cat != null -> "$verb $amtStr · ${cat.name}${sub?.let { " › ${it.name}" } ?: ""}"
            else -> "$verb $amtStr · expand to categorise & save"
        }

        builder
            .setContentTitle("$emoji $verb $amtStr")
            .setContentText(collapsedText)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomBigContentView(rv)
            .setAutoCancel(false)
            .setDeleteIntent(actionIntent(ctx, notifId, "dismiss", null))

        // Optional title, typed inline like a WhatsApp reply. Only on the
        // subcategory step, so the main flow stays tap-tap-Save.
        if (step == "sub") {
            val title = state.optString("title")
            if (title.isNotEmpty()) builder.setSubText("“$title”")
            val input = RemoteInput.Builder(KEY_TITLE_INPUT)
                .setLabel("Title (optional)")
                .build()
            val action = NotificationCompat.Action.Builder(
                0, if (title.isEmpty()) "Add title" else "Edit title",
                actionIntent(ctx, notifId, "title", null, mutable = true)
            ).addRemoteInput(input).setAllowGeneratedReplies(false).build()
            builder.addAction(action)
        }

        nm(ctx).notify(notifId, builder.build())
    }

    private fun dotLabel(name: String, color: Int): CharSequence {
        val sb = SpannableStringBuilder("● ").append(name)
        sb.setSpan(ForegroundColorSpan(color), 0, 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        return sb
    }

    // ── Saving ────────────────────────────────────────────────────────────────

    private fun queueTransaction(ctx: Context, state: JSONObject) {
        val txn = JSONObject()
        txn.put("id", UUID.randomUUID().toString())
        txn.put("type", state.optString("type", "expense"))
        txn.put("amount", state.getDouble("amount"))
        txn.put("categoryId", state.getString("catId"))
        state.optString("subId").ifEmpty { null }?.let { txn.put("subcategoryId", it) }
        txn.put("paymentMode", state.optString("paymentMode", "bankTransfer"))
        txn.put("date", state.optLong("ts", System.currentTimeMillis()))
        txn.put("createdAt", System.currentTimeMillis())
        state.optString("title").ifEmpty { null }?.let { txn.put("title", it) }

        val p = prefs(ctx)
        val list = JSONArray(p.getString(KEY_SAVED, "[]"))
        list.put(txn)
        p.edit().putString(KEY_SAVED, list.toString()).commit()

        // Drop the raw SMS from the review queue so it doesn't show up again
        // in "Pending review" next time the app opens.
        val notifId = state.getInt("notifId")
        val smsPrefs = ctx.getSharedPreferences(SmsReceiver.PREFS_NAME, Context.MODE_PRIVATE)
        val smsList = JSONArray(smsPrefs.getString(SmsReceiver.KEY_SMS_LIST, "[]"))
        val kept = JSONArray()
        for (i in 0 until smsList.length()) {
            val o = smsList.optJSONObject(i) ?: continue
            if (o.optInt("notifId", -1) != notifId) kept.put(o)
        }
        smsPrefs.edit().putString(SmsReceiver.KEY_SMS_LIST, kept.toString()).commit()
    }

    // ── Plumbing ──────────────────────────────────────────────────────────────

    private fun actionIntent(
        ctx: Context, notifId: Int, action: String, arg: String?, mutable: Boolean = false,
    ): PendingIntent {
        // RemoteInput needs a mutable PendingIntent so the system can attach the typed text.
        val mutability = if (mutable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            PendingIntent.FLAG_MUTABLE else PendingIntent.FLAG_IMMUTABLE
        val intent = Intent(ctx, QuickSaveReceiver::class.java).apply {
            this.action = QuickSaveReceiver.ACTION
            // A unique data URI keeps each chip's PendingIntent distinct.
            data = Uri.parse("kit-quicksave://$notifId/$action/${Uri.encode(arg ?: "")}")
            putExtra("notifId", notifId)
            putExtra("action", action)
            putExtra("arg", arg)
        }
        return PendingIntent.getBroadcast(
            ctx, notifId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or mutability
        )
    }

    private fun openAppIntent(ctx: Context, notifId: Int): PendingIntent {
        val launch = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }
        return PendingIntent.getActivity(
            ctx, notifId, launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = nm(ctx)
        if (manager.getNotificationChannel(CHANNEL_ID) == null) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Transaction Alerts", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Alerts when a bank transaction SMS is detected."
                }
            )
        }
    }

    fun cancel(ctx: Context, notifId: Int) = nm(ctx).cancel(notifId)

    fun clearState(ctx: Context, notifId: Int) {
        prefs(ctx).edit().remove(STATE_PREFIX + notifId).apply()
    }

    private fun saveState(ctx: Context, notifId: Int, state: JSONObject) {
        prefs(ctx).edit().putString(STATE_PREFIX + notifId, state.toString()).commit()
    }

    private fun loadState(ctx: Context, notifId: Int): JSONObject? =
        prefs(ctx).getString(STATE_PREFIX + notifId, null)?.let {
            try { JSONObject(it) } catch (e: Exception) { null }
        }

    private fun prefs(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private fun nm(ctx: Context) = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
}

/** Receives chip / button taps from the quick-save notification. Not exported. */
class QuickSaveReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION = "com.keepintrack.keep_in_track.QUICK_SAVE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return
        val notifId = intent.getIntExtra("notifId", -1)
        val action  = intent.getStringExtra("action") ?: return
        if (notifId == -1) return

        if (action == "dismiss") {
            // Swiped away: forget the state. The SMS stays in the review queue.
            QuickSaveNotifier.clearState(context, notifId)
            return
        }
        val arg = if (action == "title") {
            RemoteInput.getResultsFromIntent(intent)
                ?.getCharSequence(QuickSaveNotifier.KEY_TITLE_INPUT)?.toString()
        } else {
            intent.getStringExtra("arg")
        }
        QuickSaveNotifier.handle(context, notifId, action, arg)
    }
}
