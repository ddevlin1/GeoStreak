# Business model

## Positioning

A fast, repeatable geography game built around streak pressure rather than long sessions. The differentiator is configurable accuracy and clue type, plus daily competitive seeds.

## Free tier

- Unlimited city-name country streaks
- One daily challenge
- Basic stats and local best streak
- A small, non-intrusive ad after a completed run, never during a run

## Plus tier: $2.99/month or $19.99/year

- No ads
- 5 km, 50 km, and custom-radius modes
- Landmark and history clue packs
- Offline regional map downloads
- Advanced statistics, streak calendar, and friend leagues
- Custom challenge creation and sharing

## One-time purchases

- Themed packs at $1.99-$4.99: world capitals, ancient history, US national parks, football cities, architecture, etc.
- Optional lifetime unlock around $39.99 for early adopters

## Cost discipline

- Keep game content and scoring on-device.
- Use CloudKit/Game Center first to avoid operating a custom backend.
- Store map archives in object storage/CDN only after traffic warrants it.
- Generate clue packs offline from open datasets, review them, then ship versioned JSON.
- Add a backend only for cross-platform accounts, moderation, or real-time multiplayer.

## Example modest-revenue case

At 10,000 monthly active users:
- 2% annual subscribers at $19.99 = about $4,000 gross annual recurring revenue
- 3% buy one $2.99 pack annually = about $900 gross
- Light ads can add a small supplemental amount depending on geography and engagement

The realistic early goal is covering the Apple developer fee, map hosting, analytics, and content work—not maximizing ad load.
