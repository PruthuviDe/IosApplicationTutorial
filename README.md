# GameVault — iOS Gaming Hub

> A polished, multi-game iOS application built with SwiftUI across 4 weeks of coursework.  
> Tap Frenzy · Light It Up · Quiz Rush

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Features by Week](#features-by-week)
- [Setup & Running](#setup--running)
- [Known Limitations](#known-limitations)
- [Reflection](#reflection)

---

## Overview

GameVault is a native iOS gaming hub that houses three distinct mini-games inside a unified, dark-themed shell application. The app integrates real device capabilities — CoreLocation, UserNotifications, MapKit, SwiftUI Charts, and a live REST API — into a cohesive, production-quality experience built entirely in SwiftUI.

---

## Tech Stack

| Technology | Usage |
|---|---|
| **SwiftUI** | All UI layers — tabs, games, components |
| **Swift Concurrency (async/await)** | API fetching in QuizViewModel |
| **Combine** | Timer publishing in Tap Frenzy |
| **MapKit** | Interactive pin map in Map tab |
| **CoreLocation** | GPS coordinate capture on game completion |
| **UserNotifications** | Scheduled daily challenge reminders |
| **SwiftUI Charts** | Score history bar chart in Stats tab |
| **Open Trivia Database API** | Live trivia questions for Quiz Rush |
| **UserDefaults + JSON** | Persistent session storage via SessionStore |

---

## Architecture

GameVault follows a strict **MVVM (Model-View-ViewModel)** architecture with services extracted into dedicated singleton classes.

```
┌─────────────────────────────────────────────────────┐
│                       Views                          │
│   Tabs/         Games/          Components/          │
│  HomeTab       TapFrenzy        GameTile             │
│  StatsTab      LightItUp        ScoreBadge           │
│  MapTab        QuizRush         PrimaryButton        │
│  SettingsTab                                         │
└──────────────────┬──────────────────────────────────┘
                   │ observes / calls
┌──────────────────▼──────────────────────────────────┐
│               ViewModels & Services                  │
│   QuizViewModel    SessionStore   LocationService    │
│                    NotificationService QuizService   │
└──────────────────┬──────────────────────────────────┘
                   │ uses
┌──────────────────▼──────────────────────────────────┐
│                     Models                           │
│         GameMode    GameSession    QuizQuestion      │
└─────────────────────────────────────────────────────┘
```

### Key Principles
- **Views** contain only rendering logic — no business logic, no network calls
- **ViewModels** own published state and coordinate async operations
- **Services** are singletons wrapping platform APIs (location, notifications, networking, storage)
- **Models** are pure value types (`struct`) with `Codable` conformance for persistence

---

## Folder Structure

```
IosApplicationTutorial/
├── App/
│   └── IosApplicationTutorialApp.swift     # App entry point, TabView shell
│
├── Models/
│   ├── Card.swift                            # Struct: id, isLit, CardColor enum
│   ├── DifficultySnapshot.swift              # Score-based difficulty algorithm for Light It Up
│   ├── GameMode.swift                        # Enum: .tapFrenzy, .lightItUp, .quizRush
│   │                                         # Properties: icon, imageName, accentColor, subtitle
│   ├── GameSession.swift                     # Struct: id, mode, score, timestamp, lat, lon
│   ├── QuizQuestion.swift                    # Codable struct + HTML entity decoder
│   └── TapButtonType.swift                   # Enum: .normal, .bonus, .trap for Tap Frenzy
│
├── ViewModels/
│   ├── TapFrenzyViewModel.swift             # Tap game logic, combo system, burst mode
│   ├── LightItUpViewModel.swift             # Grid game logic, progressive difficulty
│   ├── QuizViewModel.swift                  # Quiz state, async load(), answer()
│   └── StatsViewModel.swift                 # Bridges SessionStore → StatsTab
│
├── Services/
│   ├── LocationService.swift                # CLLocationManager wrapper, .coordinate
│   ├── NotificationService.swift            # UNUserNotificationCenter, daily trigger
│   ├── QuizService.swift                    # URLSession + OpenTDB API client
│   └── SessionStore.swift                   # JSON persistence in UserDefaults
│
├── Views/
│   ├── Tabs/
│   │   ├── HomeTab.swift                    # Game selector with artwork tiles
│   │   ├── StatsTab.swift                   # Dashboard: badges, chart, recent games
│   │   ├── MapTab.swift                     # MapKit pins + session detail sheet
│   │   └── SettingsTab.swift                # Notifications, data reset, about
│   │
│   ├── Games/
│   │   ├── TapFrenzy/
│   │   │   └── TapFrenzyView.swift          # Tap game with combos, traps, burst mode
│   │   ├── LightItUp/
│   │   │   ├── LightItUpMenuView.swift      # Mode + round length selector
│   │   │   └── LightItUpView.swift          # Grid game, progressive difficulty
│   │   └── QuizRush/
│   │       ├── QuizMenuView.swift           # Category, difficulty, amount, timer
│   │       └── QuizView.swift               # Trivia game with streak scoring
│   │
│   ├── Shared/
│   │   └── ResultView.swift                 # Game over screen, shared by all 3 games
│   │
│   └── Components/
│       ├── GameTile.swift                   # Home screen game card with artwork
│       ├── ScoreBadge.swift                 # Stat metric badge with icon + value
│       └── PrimaryButton.swift              # Reusable styled action button
│
└── Assets.xcassets/
    ├── tap_frenzy.imageset/                 # Custom game artwork image
    ├── light_it_up.imageset/                # Custom game artwork image
    └── quiz_rush.imageset/                  # Custom game artwork image
```

---

## Features by Week

### Week 1 — Tap Frenzy
**Goal:** Build the smallest possible game that's fun, then make it harder.

| Feature | Description |
|---|---|
| Tap button | Large centered button that scores on tap |
| 10-second timer | `Timer.publish` countdown with live display |
| Score counter | Increments per tap, displayed prominently |
| Game Over screen | Final score display after time expires |
| High Score | Computed from `SessionStore` — single source of truth |
| **Bonus: Combo system** | Rapid taps stack multipliers for extra points |
| **Bonus: Trap buttons** | Button changes type (green = bonus, grey = trap) |
| **Bonus: Moving button** | Target relocates randomly for increasing difficulty |
| **Bonus: Burst mode** | High streaks trigger a rapid-fire scoring burst |

---

### Week 2 — Light It Up
**Goal:** Add a second game — cards appear, one lights up, tap it before it goes dark.

| Feature | Description |
|---|---|
| Grid mechanic | Cards in a fixed-size grid; one or more illuminate briefly |
| Progressive difficulty | Score-based algorithm — `cardCount`, `litWindow`, `colorCount` all scale with score |
| Multi-colour cards | Cyan, green, orange, red — unlocks at score 10+ |
| Sequence mode | At score 30+, tap cards in a specific colour order |
| Timed + Endless modes | Player chooses between countdown timer or infinite play |
| Lives system | 3 lives — miss or mis-tap costs a life |
| High Score | Computed from `SessionStore` — single source of truth |
| Menu screen | Mode selector (Timed/Endless) + round length picker |

---

### Week 3 — Quiz Rush
**Goal:** Add a third mode powered by a live API; introduce async/await and MVVM.

| Feature | Description |
|---|---|
| OpenTDB API | Fetches live trivia questions with no API key required |
| MVVM ViewModel | `QuizViewModel` manages state, loading, and error conditions |
| Loading state | Activity indicator while API request is in flight |
| Error state | Friendly error screen with retry button on network failure |
| 4 answer buttons | Correct + 3 incorrect answers shuffled randomly |
| Streak scoring | Consecutive correct answers give compounding bonus points |
| Penalty system | Wrong answers deduct points and reset streak |
| Menu customization | Select category, difficulty (easy/medium/hard), question count |

---

### Week 4 — The Real App
**Goal:** Restructure into a real app shell with tabs, persistence, location, and notifications.

| Feature | Description |
|---|---|
| TabView shell | Home, Stats, Map, Settings — all in a unified `TabView` |
| MVVM restructure | Full folder hierarchy: Models, ViewModels, Services, Views |
| GameSession model | Records id, mode, score, timestamp, and GPS coordinates |
| SessionStore | JSON-encoded UserDefaults persistence for all sessions |
| Stats tab | Total games, total score, personal bests, bar chart, recent games |
| SwiftUI Charts | `BarMark` chart showing score history per game session |
| Map tab | MapKit pins for every game location; tap for session detail sheet |
| Settings tab | Daily notification toggle + time picker, data reset with confirmation |
| ShareLink | Share score result on all three game over screens |
| Custom artwork | Premium AI-generated game cover images in Home tiles and menus |
| Glassmorphism UI | Gradient card backgrounds, radial background glow, bright borders |

---

## Setup & Running

### Requirements
- Xcode 16+
- iOS 17+ Simulator or physical device
- macOS Sonoma or later
- No third-party package dependencies — uses only native Apple frameworks

### Steps

```bash
# Clone the repository
git clone https://github.com/PruthuviDe/IosApplicationTutorial.git
cd IosApplicationTutorial

# Open in Xcode
open IosApplicationTutorial.xcodeproj
```

1. Select a simulator target (iPhone 16 recommended)
2. Press `Cmd + R` to build and run
3. Grant **Location** and **Notifications** permissions when prompted on first launch

> **Note:** Quiz Rush requires an active internet connection to query the Open Trivia Database API.

---

## Known Limitations

| Area | Limitation |
|---|---|
| **Quiz Rush offline** | No offline fallback — shows an error screen if the OpenTDB API is unreachable |
| **Location accuracy** | Uses `kCLLocationAccuracyHundredMeters` to preserve battery; pins may appear slightly offset |
| **Session storage limit** | All sessions stored in UserDefaults — not suitable for very large volumes (1000+ sessions) |
| **ViewModels scope** | All 3 games use dedicated ViewModels; minor logic remains in QuizView for animation timing |
| **No user profile** | Player name is editable in Settings and persists via `@AppStorage` — no authentication system |

---

## Reflection

Building GameVault across four weeks was a genuinely rewarding experience in scaling a SwiftUI codebase from a single-screen prototype into a multi-feature, platform-integrated app.

**Week 1** established the importance of clean state management from the start — even a simple tap counter benefits from disciplined use of `@State` and `@AppStorage`. Adding combos and trap logic showed how quickly a simple mechanic can become interesting.

**Week 2** introduced the first real architecture challenge: coordinating a timer, a grid state, level logic, and a lives system simultaneously inside SwiftUI's reactive model. Separating the grid state from the timer state was the key insight.

**Week 3** was the most technically educational. Implementing `async/await` with proper `ViewState` handling (loading, loaded, failed) made the difference between a fragile network call and a resilient user experience. Seeing MVVM click in practice — where the view simply reflects published state — was a turning point.

**Week 4** was about assembling everything into a coherent product. Integrating CoreLocation, MapKit annotations, UNUserNotifications, and SwiftUI Charts in a single sprint demonstrated how much Apple's native frameworks can accomplish with relatively little code. The most challenging aspect was ensuring all services are initialized cleanly in the App lifecycle and that `SessionStore` correctly bridges all three games through a single persistence layer.

The biggest lesson: **architecture decisions made early pay compounding dividends**. The MVVM restructure in Week 4 was straightforward because the individual game logic was already reasonably contained. Had all state lived in a single `ContentView`, the refactor would have been painful.
