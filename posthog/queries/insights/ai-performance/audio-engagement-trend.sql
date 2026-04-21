-- Audio Engagement Trend (TASK-011)
-- Weekly count of unique users who started audio at least once.
-- Goes on the AI Feature Performance dashboard; pair with the Audio
-- Engagement funnel to read "is the top-of-funnel growing?".

SELECT
  toStartOfWeek(timestamp) AS week,
  count(DISTINCT distinct_id) AS unique_listeners,
  count() AS total_playback_starts,
  count() / count(DISTINCT distinct_id) AS avg_starts_per_listener
FROM events
WHERE event = 'AUDIO_PLAYBACK_STARTED'
  AND timestamp >= now() - INTERVAL 90 DAY
GROUP BY week
ORDER BY week ASC;
