# Hindi Dataset (Separate Directory)

This directory contains Hindi-first JSON datasets, kept separate from `assets/data/` so the English dataset remains default.

Current Hindi dataset coverage:
- Emotional check-in forms (Part 1-4)
- Relationship Monitoring
- Communication Tracker

Suggested usage:
- Keep default app language and dataset source as English.
- When user switches language to Hindi, load the equivalent `assets/data_hi/*` file.
- If a Hindi file is missing, safely fallback to `assets/data/*`.

