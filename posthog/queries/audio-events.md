# Audio Event Catalog — feat-explanation-audio

Six events fire for the explanation-audio feature across server + web +
mobile. This catalog is the contract between the three emitting
surfaces and the PostHog insights that observe them. Add new properties
by updating (a) the emitter, (b) the TypeScript type in
`frontend-base/src/analytics/types.ts` (or the mobile/server equivalent),
and (c) this document — in that order.

---

## AUDIO_PLAYBACK_STARTED

**Fired by:** Web (frontend-base `useAudioPlayerStore` + wrapped hook) ·
Mobile (`verse-mate-mobile` AudioPlayerContext). Once per Play gesture —
not for the `setInterval` resume saves.

**Triggered by:** user tapping Play on a loaded audio. A resume-chip tap
also fires this with `isResume=true`.

| property | type | notes |
|---|---|---|
| `explanationId` | number | FK to `explanations.explanation_id` |
| `explanationType` | string | `summary` / `byline` / `detailed` |
| `bookId` | number | 1..66 |
| `chapterNumber` | number | 1-based |
| `voice` | string | e.g. `alloy`, `nova` |
| `languageCode` | string | ISO-2 |
| `isResume` | boolean | `true` when the user consumed a saved position |
| `resumePositionSeconds` | number? | Only when `isResume=true` |
| `ttsProvider` | string | `openai` or `stub` |

---

## AUDIO_PLAYBACK_PAUSED

**Fired by:** Web + Mobile when the player transitions from `playing`
→ `paused`. Also fires when the app is backgrounded mid-playback (mobile
only; web pauses visibly).

| property | type | notes |
|---|---|---|
| `explanationId` | number | |
| `positionSeconds` | number | Where the user paused |
| `durationSeconds` | number | Audio's total duration at pause time |
| `reason` | `"user" \| "background" \| "navigation"` | `user` = tap Pause; `background` = app backgrounded (mobile); `navigation` = page unload handler fired |

---

## AUDIO_PLAYBACK_COMPLETED

**Fired by:** Web + Mobile when the HTMLAudio / expo-av element emits
`ended`. Server clears the resume row concurrently via the POST with
`reason: "complete"` the player sends.

| property | type | notes |
|---|---|---|
| `explanationId` | number | |
| `durationSeconds` | number | Final total duration |
| `completedBy` | `"natural" \| "skipped"` | `natural` = reached end; `skipped` = user tapped to next chapter near the end (future) |

---

## AUDIO_PLAYBACK_SEEK

**Fired by:** Web + Mobile when the user scrubs, taps ±15s, or chooses a
specific position. Rate-limited client-side to 1 event / 500ms to avoid
scrubber spam.

| property | type | notes |
|---|---|---|
| `explanationId` | number | |
| `fromSeconds` | number | Position before seek |
| `toSeconds` | number | Position after seek |
| `direction` | `"forward" \| "backward"` | Derived client-side |

---

## AUDIO_SPEED_CHANGED

**Fired by:** Web + Mobile on every speed-menu selection.

| property | type | notes |
|---|---|---|
| `explanationId` | number | |
| `fromSpeed` | number | Previous speed (0.75 / 1 / 1.25 / 1.5 / 2) |
| `toSpeed` | number | New speed |

---

## AUDIO_GENERATION_FAILED (server-side)

**Fired by:** backend `audio-generation.worker.ts` when the BullMQ job
transitions to `failed` after retries are exhausted. Properties include
the explanation id, the TTS provider, and the failure reason captured
from `job.failedReason`.

**Note:** not yet emitted — worker currently logs the failure to stdout
but does not call `posthog.capture` because `PosthogService` only exposes
`captureException`. Gate: extend the service with a generic `captureEvent`
and wire the worker's `failed` handler to it. Tracking in discoveries
D-012.

| property | type | notes |
|---|---|---|
| `explanationId` | number | |
| `voice` | string | |
| `languageCode` | string | |
| `ttsProvider` | string | `openai` / `stub` |
| `errorCode` | string | Extracted from `job.failedReason` |
| `attempts` | number | BullMQ `job.attemptsMade` |

---

## Emitter matrix

| event | backend | web | mobile |
|---|---|---|---|
| AUDIO_PLAYBACK_STARTED | — | ✓ | ✓ |
| AUDIO_PLAYBACK_PAUSED | — | ✓ | ✓ |
| AUDIO_PLAYBACK_COMPLETED | — | ✓ | ✓ |
| AUDIO_PLAYBACK_SEEK | — | ✓ | ✓ |
| AUDIO_SPEED_CHANGED | — | ✓ | ✓ |
| AUDIO_GENERATION_FAILED | ⚠ deferred | — | — |

## Funnel

`Funnel - Audio Engagement` (defined in `definitions/funnels.ts`):

1. `CHAPTER_VIEWED`
2. `EXPLANATION_TAB_CHANGED`
3. `AUDIO_PLAYBACK_STARTED`
4. `AUDIO_PLAYBACK_COMPLETED`

Window: 30 minutes. Dashboard: **AI Feature Performance**.
