-- Insight: Number - Audio Completion Rate
-- Dashboard: AI Feature Performance
-- Visualization: Number card
-- Time window: Last 7 days
-- Description: Percentage of started audio sessions that complete naturally.
--              Formula: AUDIO_PLAYBACK_COMPLETED / AUDIO_PLAYBACK_STARTED.
--              Spec target: >= 40%. Below 30% suggests audio length or content
--              mismatch — investigate explanation_type breakdown.

SELECT
    countIf(event = 'AUDIO_PLAYBACK_STARTED') AS started,
    countIf(event = 'AUDIO_PLAYBACK_COMPLETED') AS completed,
    round(
        countIf(event = 'AUDIO_PLAYBACK_COMPLETED') * 100.0
        / nullIf(countIf(event = 'AUDIO_PLAYBACK_STARTED'), 0),
        1
    ) AS completion_rate_pct
FROM events
WHERE
    event IN ('AUDIO_PLAYBACK_STARTED', 'AUDIO_PLAYBACK_COMPLETED')
    AND timestamp >= now() - INTERVAL 7 DAY;

-- Daily completion-rate trend
SELECT
    toDate(timestamp) AS day,
    countIf(event = 'AUDIO_PLAYBACK_STARTED') AS started,
    countIf(event = 'AUDIO_PLAYBACK_COMPLETED') AS completed,
    round(
        countIf(event = 'AUDIO_PLAYBACK_COMPLETED') * 100.0
        / nullIf(countIf(event = 'AUDIO_PLAYBACK_STARTED'), 0),
        1
    ) AS completion_rate_pct
FROM events
WHERE
    event IN ('AUDIO_PLAYBACK_STARTED', 'AUDIO_PLAYBACK_COMPLETED')
    AND timestamp >= now() - INTERVAL 7 DAY
GROUP BY day
ORDER BY day DESC;
