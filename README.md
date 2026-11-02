# GeoStreak iOS MVP

A native SwiftUI geography streak game using MapLibre, OpenStreetMap-derived tiles, bundled challenges, and on-device country-boundary validation.

## Run on a Mac

1. Install Xcode from the Mac App Store and open it once to accept its license.
2. Install Homebrew if needed, then run:
   ```bash
   brew install xcodegen
   ```
3. From this folder run:
   ```bash
   ./scripts/bootstrap_data.sh
   xcodegen generate
   open GeoStreak.xcodeproj
   ```
4. In Xcode, select an iPhone simulator and press Run.
5. For a physical iPhone, select your Apple developer team under **Signing & Capabilities** and choose your device.

The first Xcode build resolves MapLibre through Swift Package Manager.

## Architecture

- SwiftUI screens and state management
- MapLibre Native for rendering and map taps
- OpenFreeMap style during development
- Natural Earth country polygons bundled in the app
- Haversine distance through Core Location
- Local JSON challenge packs; no gameplay API required

## Production map strategy

Do not point a scaled commercial app at `tile.openstreetmap.org`. For launch, use one of these:

1. Host a Protomaps/OpenMapTiles PMTiles archive in inexpensive object storage and configure MapLibre to read it.
2. Self-host OpenFreeMap.
3. Keep OpenFreeMap's public service only while its terms and capacity remain appropriate, with a remote-configurable fallback.

## Suggested next milestones

- Daily challenge seed and Game Center leaderboards
- Double-or-nothing “Risk Round” every five correct guesses
- Downloadable city, landmark, history, flags, and sports packs
- Difficulty balancing by population and clue familiarity
- Account sync with CloudKit
- StoreKit 2 subscription and non-consumable themed packs
- Accessibility: VoiceOver labels, color-independent markers, haptics
- Unit tests for country polygon edge cases and scoring
