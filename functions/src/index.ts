import {initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import type {DocumentReference} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onSchedule} from "firebase-functions/v2/scheduler";

initializeApp();

const db = getFirestore();
const OPEN_STATUSES = [
  "created",
  "active",
  "updated",
  "leavingSoon",
] as const;

const ONE_DAY_MS = 24 * 60 * 60 * 1000;
const TRANSACTION_CONCURRENCY = 20;

type OpenStatus = (typeof OPEN_STATUSES)[number];

/**
 * Checks whether a session status represents an open session.
 * @param {unknown} value The value to check.
 * @return {boolean} Whether the value is an open status.
 */
function isOpenStatus(value: unknown): value is OpenStatus {
  return (
    typeof value === "string" &&
    (OPEN_STATUSES as readonly string[]).includes(value)
  );
}

export const closeExpiredParkingSessions = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "Etc/UTC",
    region: "europe-west1",
    maxInstances: 1,
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const now = Timestamp.now();
    const staleCutoff = Timestamp.fromMillis(
      now.toMillis() - ONE_DAY_MS,
    );
    const sessions = db.collection("parking_sessions");

    const [plannedEndSnapshot, staleSnapshot] = await Promise.all([
      sessions
        .where("status", "in", [...OPEN_STATUSES])
        .where("plannedEndAt", ">=", Timestamp.fromMillis(0))
        .where("plannedEndAt", "<=", now)
        .get(),
      sessions
        .where("status", "in", [...OPEN_STATUSES])
        .where("updatedAt", "<=", staleCutoff)
        .get(),
    ]);

    const candidateRefs = new Map<string, DocumentReference>();

    for (const document of plannedEndSnapshot.docs) {
      candidateRefs.set(document.ref.path, document.ref);
    }

    for (const document of staleSnapshot.docs) {
      candidateRefs.set(document.ref.path, document.ref);
    }

    const references = [...candidateRefs.values()];
    let closedCount = 0;
    let skippedCount = 0;
    let failedCount = 0;

    for (
      let start = 0;
      start < references.length;
      start += TRANSACTION_CONCURRENCY
    ) {
      const batch = references.slice(
        start,
        start + TRANSACTION_CONCURRENCY,
      );

      const outcomes = await Promise.all(
        batch.map(async (reference) => {
          try {
            const wasClosed = await db.runTransaction(
              async (transaction) => {
                const snapshot = await transaction.get(reference);

                if (!snapshot.exists) {
                  return false;
                }

                const data = snapshot.data();

                if (!data) {
                  return false;
                }

                if (!isOpenStatus(data.status)) {
                  return false;
                }

                const plannedEndAt = data.plannedEndAt;
                let isExpired: boolean;

                if (plannedEndAt instanceof Timestamp) {
                  isExpired =
                    plannedEndAt.toMillis() <= now.toMillis();
                } else if (
                  plannedEndAt === null ||
                  plannedEndAt === undefined
                ) {
                  const updatedAt = data.updatedAt;

                  if (!(updatedAt instanceof Timestamp)) {
                    logger.warn(
                      "Skipping session with invalid updatedAt",
                      {sessionId: reference.id},
                    );
                    return false;
                  }

                  isExpired =
                    updatedAt.toMillis() <= staleCutoff.toMillis();
                } else {
                  logger.warn(
                    "Skipping session with invalid plannedEndAt",
                    {sessionId: reference.id},
                  );
                  return false;
                }

                if (!isExpired) {
                  return false;
                }

                transaction.update(reference, {
                  status: "closed",
                  closedAt: FieldValue.serverTimestamp(),
                  updatedAt: FieldValue.serverTimestamp(),
                });

                return true;
              },
            );

            return wasClosed ? "closed" : "skipped";
          } catch (error) {
            logger.error(
              "Failed to close expired parking session",
              {sessionId: reference.id, error},
            );
            return "failed";
          }
        }),
      );

      for (const outcome of outcomes) {
        if (outcome === "closed") {
          closedCount++;
        } else if (outcome === "failed") {
          failedCount++;
        } else {
          skippedCount++;
        }
      }
    }

    logger.info("Parking session expiry run completed", {
      candidateCount: references.length,
      closedCount,
      skippedCount,
      failedCount,
    });
  },
);
