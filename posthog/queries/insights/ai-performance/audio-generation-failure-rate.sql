-- Insight: Number - Audio Generation Failure Rate
-- Dashboard: AI Feature Performance
-- Visualization: Number card
-- Time window: Last 7 days
-- Description: Server-side TTS job failure rate.
--              Formula: AUDIO_GENERATION_FAILED / total TTS jobs.
--              Spec target: < 1%. > 2% should page on-call.
--              The denominator approximates total jobs as
--              AUDIO_PLAYBACK_STARTED + AUDIO_GENERATION_FAILED — every
--              user-visible play maps to a job that completed (started)
--              or failed.

SELECT
    countIf(event = 'AUDIO_GENERATION_FAILED') AS failures,
    countIf(event IN ('AUDIO_PLAYBACK_STARTED', 'AUDIO_GENERATION_FAILED'))
        AS total_jobs,
    round(
        countIf(event = 'AUDIO_GENERATION_FAILED') * 100.0
        / nullIf(
            countIf(event IN ('AUDIO_PLAYBACK_STARTED', 'AUDIO_GENERATION_FAILED')),
            0
        ),
        2
    ) AS failure_rate_pct
FROM events
WHERE
    event IN ('AUDIO_PLAYBACK_STARTED', 'AUDIO_GENERATION_FAILED')
    AND timestamp >= now() - INTERVAL 7 DAY;

-- Top failure codes (drill-down)
SELECT
    properties.code AS error_code,
    count() AS failures
FROM events
WHERE
    event = 'AUDIO_GENERATION_FAILED'
    AND timestamp >= now() - INTERVAL 7 DAY
GROUP BY error_code
ORDER BY failures DESC
LIMIT 10;
