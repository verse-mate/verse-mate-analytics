-- Funnel - Audio Engagement (TASK-011)
-- Reference HogQL for the 4-step audio engagement funnel. PostHog's
-- UI funnel builds the same shape from FUNNEL_DEFINITIONS; this file
-- exists so analysts can cross-check conversions ad-hoc and so future
-- tweaks are reviewable in git.

SELECT
  e1.distinct_id AS distinct_id,
  e1.timestamp   AS step_1_at,   -- CHAPTER_VIEWED
  e2.timestamp   AS step_2_at,   -- EXPLANATION_TAB_CHANGED
  e3.timestamp   AS step_3_at,   -- AUDIO_PLAYBACK_STARTED
  e4.timestamp   AS step_4_at    -- AUDIO_PLAYBACK_COMPLETED
FROM events e1
LEFT JOIN events e2
  ON e2.distinct_id = e1.distinct_id
 AND e2.event = 'EXPLANATION_TAB_CHANGED'
 AND e2.timestamp > e1.timestamp
 AND e2.timestamp <= e1.timestamp + INTERVAL 30 MINUTE
LEFT JOIN events e3
  ON e3.distinct_id = e1.distinct_id
 AND e3.event = 'AUDIO_PLAYBACK_STARTED'
 AND e3.timestamp > e2.timestamp
 AND e3.timestamp <= e1.timestamp + INTERVAL 30 MINUTE
LEFT JOIN events e4
  ON e4.distinct_id = e1.distinct_id
 AND e4.event = 'AUDIO_PLAYBACK_COMPLETED'
 AND e4.timestamp > e3.timestamp
 AND e4.timestamp <= e1.timestamp + INTERVAL 30 MINUTE
WHERE e1.event = 'CHAPTER_VIEWED'
  AND e1.timestamp >= now() - INTERVAL 30 DAY
ORDER BY e1.timestamp DESC
LIMIT 1000;
