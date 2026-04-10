# verse-mate-analytics

PostHog dashboards, HogQL queries, and analytics tooling for Verse Mate.

## Setup

```bash
bun install
cp .env.example .env
# Fill in POSTHOG_API_KEY, POSTHOG_PROJECT_ID, POSTHOG_HOST
```

## Usage

```bash
# Preview what would be created
bun run setup:dry-run

# Create/update all dashboards
bun run setup

# Create a specific dashboard
bun posthog/setup.ts --dashboard="Executive Overview"

# List existing insights
bun run list-insights
```

## Structure

```
posthog/
├── api/              # PostHog API client
├── definitions/      # Dashboard, insight, cohort, funnel definitions
├── queries/          # HogQL .sql files
│   ├── cohorts/
│   ├── funnels/
│   └── insights/
├── utils/            # Logger, idempotent sync helpers
├── setup.ts          # Idempotent dashboard provisioning
└── list-insights.ts  # List existing insights
```

## Dashboards

| Dashboard | Description |
|-----------|-------------|
| Executive Overview | DAU/WAU/MAU, retention, activation |
| User Engagement | Reading patterns, feature usage |
| Retention & Growth | Cohorts, streaks, resurrection |
| AI Feature Performance | Tooltips, explanations |
| Technical Health | Auth, platform, sessions |
| Social & Virality | Sharing patterns |
| Error Monitoring | Error rates, crash rates, top error endpoints |
