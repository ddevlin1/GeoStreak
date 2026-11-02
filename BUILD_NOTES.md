# GeoStreak Build Instructions

## Build & Run

1. **Install Xcode dependencies:**
   ```bash
   brew install xcodegen
   ```

2. **From the repository root, bootstrap data and generate the project:**
   ```bash
   ./scripts/bootstrap_data.sh
   xcodegen generate
   open GeoStreak.xcodeproj
   ```

3. **Run in Xcode:**
   - Select iPhone simulator (or connect device)
   - Press Run (Cmd+R)

## New Features to Explore

### Story Mode
- Tap **Story Mode** from home screen
- Browse 4 historical campaigns (WWI, WWII, Hunnic Invasions, Roman Empire)
- Select a chapter and begin locating events on the map
- Score points based on accuracy (0-500 km radius)
- View final stats on completion screen

### Map Zoom
- During gameplay (both Quick Play and Story Mode), pinch to zoom in/out
- Drag to pan the map
- Zoom level from 0.5 (world) to 16.0 (street detail)

### Redesigned Home Screen
- Modern dark gradient theme
- Quick Play and Story Mode as separate, visually distinct options
- Inline settings for Quick Play (clue type, accuracy, lives)
- Feature roadmap preview

## File Structure
```
GeoStreak/
├── Models/
│   ├── GameModels.swift
│   └── StoryModels.swift (NEW)
├── Views/
│   ├── HomeView.swift (UPDATED - redesigned)
│   ├── GameView.swift
│   ├── MapView.swift (UPDATED - zoom enabled)
│   ├── StoryModeView.swift (NEW)
│   ├── StoryChapterIntroView.swift (NEW)
│   ├── StoryGameView.swift (NEW)
│   └── StoryCampaignCompleteView.swift (NEW)
├── Services/
│   ├── GameEngine.swift
│   ├── CountryIndex.swift
│   ├── ChallengeStore.swift
│   ├── StoryEngine.swift (NEW)
│   └── StoryStore.swift (NEW)
└── Resources/
    ├── challenges.json
    ├── countries.geojson
    └── stories.json (NEW - 4 campaigns, 30+ historical events)
```

## Testing Checklist
- [ ] HomeView loads with Story Mode and Quick Play buttons
- [ ] Story Mode displays 4 campaigns
- [ ] Can select a campaign and chapter
- [ ] Map shows in story gameplay and supports zoom/pan
- [ ] Events can be guessed and scored
- [ ] Campaign completion screen shows final score
- [ ] Quick Play still works as before
- [ ] All navigation transitions smoothly
