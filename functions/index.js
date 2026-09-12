/**
 * Pushes every newly created `notifications` document to all registered
 * devices via FCM.
 *
 * Why this exists: the app's in-app notification list is just a Firestore
 * snapshot listener — it can only show notifications while the app is open.
 * For a message to land in the Android/iOS system tray (and wake the app when
 * it is terminated), an actual FCM push must be delivered. This trigger is
 * that missing sender.
 *
 * Device tokens live at `users/{uid}/fcmTokens/{token}` (written by the app
 * on login / token refresh).
 */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// FCM multicast accepts at most 500 tokens per call.
const BATCH_SIZE = 500;

exports.sendNotificationPush = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data && event.data.data();
    if (!data) return null;

    const title = String(data.title || "WALLR").trim();
    const body = String(data.body || "").trim();
    if (!title && !body) return null;

    // Collect every registered device token (deduped), keeping the doc ref so
    // dead tokens can be cleaned up after the send.
    const tokenDocs = await getFirestore()
      .collectionGroup("fcmTokens")
      .get();
    const entries = [];
    const seen = new Set();
    for (const doc of tokenDocs.docs) {
      const token = doc.get("token");
      if (!token || seen.has(token)) continue;
      seen.add(token);
      entries.push({ ref: doc.ref, token });
    }
    if (entries.length === 0) {
      console.log("No registered FCM tokens; nothing to push.");
      return null;
    }

    const baseMessage = {
      notification: {
        title: title || "WALLR",
        body,
        ...(data.imageUrl ? { imageUrl: String(data.imageUrl) } : {}),
      },
      // Data payload drives deep-linking when the user taps the tray entry.
      data: {
        id: event.params.notificationId,
        type: String(data.type || "announcement"),
        route: String(data.targetRoute || ""),
      },
      android: {
        priority: "high",
        // Must match FcmService.channelId and the manifest meta-data.
        notification: { channelId: "wallr_notifications" },
      },
      apns: { payload: { aps: { sound: "default" } } },
    };

    const deadRefs = [];

    for (let i = 0; i < entries.length; i += BATCH_SIZE) {
      const batch = entries.slice(i, i + BATCH_SIZE);
      try {
        const response = await getMessaging().sendEachForMulticast({
          ...baseMessage,
          tokens: batch.map((e) => e.token),
        });
        response.responses.forEach((res, idx) => {
          if (!res.success && isPermanentError(res.error)) {
            deadRefs.push(batch[idx].ref);
          }
        });
      } catch (err) {
        console.error("Multicast send failed:", err);
      }
    }

    // Remove uninstalled/invalid tokens so future pushes stay fast.
    if (deadRefs.length > 0) {
      console.log(`Cleaning up ${deadRefs.length} stale token(s).`);
      await Promise.allSettled(
        deadRefs.map((ref) =>
          ref.set({ token: FieldValue.delete() }, { merge: true })
            .catch(() => ref.delete().catch(() => {}))
        )
      );
    }

    console.log(
      `Pushed "${title}" to ${entries.length} device(s); ${deadRefs.length} stale.`
    );
    return null;
  }
);

/** Tokens that are unregistered or invalid will never succeed again. */
function isPermanentError(error) {
  if (!error) return false;
  return (
    error.code === "messaging/registration-token-not-registered" ||
    error.code === "messaging/invalid-registration-token" ||
    error.code === "messaging/unregistered"
  );
}
