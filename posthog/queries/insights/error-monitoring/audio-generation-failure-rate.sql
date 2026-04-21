-- Audio Generation Failure Rate (TASK-011)
-- 7-day rolling failure rate from AUDIO_GENERATION_FAILED events.
-- Denominator uses the sum of completions + failures so the ratio
-- doesn't blow up when the feature is quiet.
--
-- Note: as of commit (TASK-011) the server-side event is gated on the
-- PosthogService wrapper gaining a generic captureEvent. See
-- posthog/queries/audio-events.md for the status.

SELECT
  toStartOfDay(timestamp) AS day,
  countIf(event = 'AUDIO_GENERATION_FAILED') AS failures,
  countIf(event = 'AUDIO_PLAYBACK_STARTED') AS started,
  round(
    countIf(event = 'AUDIO_GENERATION_FAILED')
      / greatest(
          countIf(event = 'AUDIO_GENERATION_FAILED')
            + countIf(event = 'AUDIO_PLAYBACK_STARTED'),
          1
        ),
    4
  ) AS failure_rate
FROM events
WHERE event IN ('AUDIO_GENERATION_FAILED', 'AUDIO_PLAYBACK_STARTED')
  AND timestamp >= now() - INTERVAL 7 DAY
GROUP BY day
ORDER BY day ASC;
