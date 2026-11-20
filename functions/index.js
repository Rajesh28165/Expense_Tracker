
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

const {onRequest} = require("firebase-functions/v2/https");
const {defineString} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

initializeApp();

const db = getFirestore();

const webApiKey = defineString("WEB_API_KEY");

exports.completePasswordReset = onRequest(
    {
      region: "asia-south1",
      maxInstances: 5,
      cors: [
        "https://kharcha-sutra.web.app",
        "https://kharcha-sutra.firebaseapp.com",
      ],
    },
    async (req, res) => {
      if (req.method !== "POST") {
        return res.status(405).json({
          success: false,
          message: "Method not allowed",
        });
      }

      const {oobCode, newPassword} = req.body || {};

      if (
        typeof oobCode !== "string" ||
      !oobCode.trim() ||
      typeof newPassword !== "string" ||
      !newPassword.trim()
      ) {
        return res.status(400).json({
          success: false,
          message: "Reset code and new password are required.",
        });
      }

      try {
      // Validate the one-time code and update the password.
        const response = await fetch(
            "https://identitytoolkit.googleapis.com/v1/" +
          "accounts:resetPassword?key=" +
          encodeURIComponent(webApiKey.value()),
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                oobCode,
                newPassword,
              }),
            },
        );

        const result = await response.json();

        if (!response.ok) {
          logger.warn("Password reset rejected", {
            error: result.error?.message || "UNKNOWN_ERROR",
          });

          return res.status(400).json({
            success: false,
            message: "The reset link is invalid or expired.",
          });
        }

        if (
          result.requestType !== "PASSWORD_RESET" ||
        typeof result.email !== "string"
        ) {
          return res.status(400).json({
            success: false,
            message: "Invalid password reset request.",
          });
        }

        // Password has now been successfully updated.
        logger.info("Password reset completed.");

        // Notification delivery is a separate step.
        // A notification failure must not undo the password reset.
        let notificationSent = 0;

        try {
          const user = await getUserByEmail(result.email);

          if (user) {
            notificationSent = await sendPasswordResetNotification(user.uid);
          }
        } catch (error) {
          logger.error("Password reset notification failed", error);
        }

        return res.status(200).json({
          success: true,
          message: "Password updated successfully.",
          notificationSent,
        });
      } catch (error) {
        logger.error("Password reset function failed", error);

        return res.status(500).json({
          success: false,
          message: "Unable to complete password reset.",
        });
      }
    },
);

// Find the user through Firebase Admin SDK.
/**
 * Retrieves a Firebase user by email.
 * @param {string} email User's verified email address.
 * @return {Promise<Object>} The Firebase user record.
 */
async function getUserByEmail(email) {
  const {getAuth} = require("firebase-admin/auth");

  return getAuth().getUserByEmail(email);
}

// Retrieve registered FCM tokens and send notifications.
/**
 * Sends password reset notifications to registered devices.
 * @param {string} uid Firebase user ID.
 * @return {Promise<number>} Number of successfully sent notifications.
 */
async function sendPasswordResetNotification(uid) {
  const tokenSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("fcmTokens")
      .get();

  const registeredTokens = tokenSnapshot.docs
      .map((doc) => ({
        token: doc.data().token,
        ref: doc.ref,
      }))
      .filter((item) => typeof item.token === "string" && item.token);

  if (registeredTokens.length === 0) {
    logger.info("No registered FCM tokens found.");
    return 0;
  }

  let successCount = 0;

  // Firebase multicast requests support up to 500 tokens.
  for (let i = 0; i < registeredTokens.length; i += 500) {
    const batch = registeredTokens.slice(i, i + 500);

    const response = await getMessaging().sendEachForMulticast({
      tokens: batch.map((item) => item.token),

      notification: {
        title: "Password Changed Successfully",
        body: "Your Kharcha Sutra account password was updated.",
      },

      data: {
        type: "password_reset_success",
        route: "login",
      },

      android: {
        priority: "high",
      },

      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    successCount += response.successCount;

    // Remove expired or invalid FCM tokens.
    const invalidCodes = [
      "messaging/invalid-registration-token",
      "messaging/registration-token-not-registered",
    ];

    const deletions = [];

    response.responses.forEach((item, index) => {
      if (
        !item.success &&
        invalidCodes.includes(item.error?.code)
      ) {
        deletions.push(batch[index].ref.delete());
      }
    });

    await Promise.all(deletions);
  }

  logger.info("Password reset notification processing completed.", {
    successCount,
  });

  return successCount;
}
