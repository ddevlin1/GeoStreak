# LLM Readme: History Unmapped (GeoStreak)

This file gives AI coding agents fast, practical context for working on this iOS app.

## 1) Product Snapshot

- App name: History Unmapped (project name: GeoStreak)
- Platform: iOS (SwiftUI)
- Core loop: player reads a clue, taps a map location, and is scored by country match or distance rule.
- Modes:
  - Quick Play: streak + lives gameplay.
  - Story Mode: historical campaigns with chapters/events and cumulative score.

## 2) Tech Stack

- Language: Swift 5.10
- UI: SwiftUI
- Map: MapLibre Native (SPM dependency)
- Geo validation: bundled GeoJSON country polygons + point-in-polygon lookup
- Data source: local bundled JSON files (no backend required for gameplay)
- Audio: AVAudioPlayer looped background music
- Target: iOS 17+

## 3) Project Structure (Important Files)

- App entry:
  - GeoStreak/App/GeoStreakApp.swift
- Models:
  - GeoStreak/Models/GameModels.swift
  - GeoStreak/Models/StoryModels.swift
- Services (logic and data):
  - GeoStreak/Services/GameEngine.swift
  - GeoStreak/Services/StoryEngine.swift
  - GeoStreak/Services/ChallengeStore.swift
  - GeoStreak/Services/StoryStore.swift
  - GeoStreak/Services/CountryIndex.swift
  - GeoStreak/Services/MusicPlayer.swift
- Views:
  - GeoStreak/Views/LaunchView.swift
  - GeoStreak/Views/HomeView.swift
  - GeoStreak/Views/GameView.swift
  - GeoStreak/Views/MapView.swift
  - GeoStreak/Views/StoryModeView.swift
  - GeoStreak/Views/StoryGameView.swift
  - GeoStreak/Views/StoryChapterIntroView.swift
  - GeoStreak/Views/StoryCampaignCompleteView.swift
- Resource data:
  - GeoStreak/Resources/Data/challenges.json
  - GeoStreak/Resources/Data/stories.json
  - GeoStreak/Resources/Data/countries.geojson
- Static images/audio:
  - GeoStreak/Resources/Images/*.png
  - GeoStreak/Resources/Audio/Prairie Concord.mp3
- Project generation config:
  - project.yml

## 4) Architecture Overview

### UI and state ownership

- The app launches into LaunchView, then transitions to HomeView.
- HomeView owns GameSettings for Quick Play and navigates to GameView with a new GameEngine.
- Engines are @MainActor ObservableObject types that publish gameplay/story state.

### Quick Play flow

1. HomeView builds GameSettings (clue type, accuracy rule, lives).
2. GameView receives GameEngine(settings:).
3. GameEngine loads and filters challenges by clue type.
4. User taps map -> selected coordinate.
5. GameEngine.submit computes:
   - distance (CoreLocation haversine)
   - country code at guess (CountryIndex point-in-polygon)
   - correctness from AccuracyRule
6. Engine updates streak/lives/result and end-state.

### Story Mode flow

1. Story campaigns are loaded from stories.json via StoryStore.
2. StoryEngine tracks campaign -> chapter -> event progression.
3. submit(guess:) computes distance and marks correctness (currently threshold: < 500 km).
4. Score and progress are updated, then phase advances through reveal/next event/chapter completion.

### Map integration

- MapView is UIViewRepresentable around MLNMapView.
- It supports map taps, zoom, and pan.
- It draws user/answer pins and animates country highlight overlay layers from countries.geojson.

## 5) Data Contracts

### Quick Play models

- Challenge (Codable): city, country, countryCode, latitude/longitude, landmark, historyClue, difficulty.
- GameSettings:
  - clueType: city | landmark | history
  - accuracyRule: country | kilometers(Int)
  - lives: Int

### Story models

- StoryCampaign -> [StoryChapter] -> [StoryEvent]
- Campaign themes drive visual gradients and accent colors.

## 6) Build and Run Workflow

From repository root:

1. ./scripts/bootstrap_data.sh
2. xcodegen generate
3. open GeoStreak.xcodeproj

Quick CLI build check:

- DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -scheme GeoStreak -destination 'generic/platform=iOS Simulator' -configuration Debug CODE_SIGNING_ALLOWED=NO build

## 7) Resource and Naming Rules

- Resources are explicitly listed in project.yml (not asset catalogs).
- If you add/rename resource files, update project.yml and regenerate project with xcodegen.
- Image file naming is case-sensitive; verify exact spelling when changing image references.
- Current menu/launch logic supports both naming variants for menu background (MenuBackground and Menubackground) for robustness.

## 8) Persistence and Side Effects

- Persisted today:
  - bestStreak in UserDefaults
- Local-only game content:
  - JSON files loaded from bundle
- Audio:
  - MusicPlayer starts on app init and uses volume modifiers across menu/game screens.

## 9) Common Safe Edit Patterns for Agents

- New UI behavior:
  - Prefer isolated View components in GeoStreak/Views.
- New gameplay rules:
  - Modify GameEngine or StoryEngine first, then adjust corresponding views.
- New challenge/story content:
  - Edit JSON files and ensure Codable compatibility.
- New resources:
  - Add file under GeoStreak/Resources, then update project.yml and run xcodegen generate.

## 10) High-Risk Areas (Read Before Refactors)

- CountryIndex geometry parsing and point-in-polygon math.
- MapView layer/source IDs and map style load timing.
- Navigation and state transitions between story phases.
- Resource naming/case mismatches for images/audio.

## 11) Known Functional Expectations

- Launch screen should show HistoryUnmappedImage and then transition to HomeView.
- Menu screen should show background image and respect notch safe area.
- Home menu content should maintain full-width layout across device sizes.
- Quick Play and Story Mode should both keep map zoom/pan enabled.

## 12) Suggested First Checks for Any Change

1. Build succeeds with xcodebuild.
2. App launches and transition LaunchView -> HomeView works.
3. Quick Play round can be started and guessed on map.
4. Story campaign can be entered and at least one event completed.
5. No regressions in top safe-area/notch spacing on HomeView.
