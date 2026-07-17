# GameVault — iOS Gaming Hub

> A polished, multi-game iOS application built with SwiftUI across 4 weeks of coursework.  
> Tap Frenzy · Light It Up · Quiz Rush

---

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
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

## Screenshots

<table>
  <tr>
    <td align="center"><b>🎮 Games (Home)</b></td>
    <td align="center"><b>📊 Stats</b></td>
  </tr>
  <tr>
    <td><img src="https://i.ibb.co/ycNMXD44/image.png" width="220"/></td>
    <td><img src="https://i.ibb.co/FbhFgH8d/image.png" width="220"/></td>
  </tr>
  <tr>
    <td align="center"><b>🗺️ Map</b></td>
    <td align="center"><b>⚙️ Settings</b></td>
  </tr>
  <tr>
    <td><img src="https://i.ibb.co/kVSbC0f4/image.png" width="220"/></td>
    <td><img src="https://i.ibb.co/6cVqYxgg/image.png" width="220"/></td>
  </tr>
</table>

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

```mermaid
flowchart TD
    subgraph Views["🖼️ Views"]
        direction LR
        Tabs["Tabs\nHomeTab · StatsTab · MapTab · SettingsTab"]
        Games["Games\nTapFrenzy · LightItUp · QuizRush"]
        Components["Components\nGameTile · ScoreBadge · PrimaryButton"]
    end

    subgraph ViewModels["⚙️ ViewModels"]
        TFV["TapFrenzyViewModel\nCombo · Burst · Timer"]
        LIU["LightItUpViewModel\nGrid · Lives · Difficulty"]
        QV["QuizViewModel\nasync load() · answer()"]
        SVM["StatsViewModel\nBridges SessionStore → Stats"]
    end

    subgraph Services["🔧 Services"]
        SS["SessionStore\nJSON · UserDefaults"]
        LS["LocationService\nCoreLocation"]
        NS["NotificationService\nUNUserNotificationCenter"]
        QS["QuizService\nOpenTDB REST API"]
    end

    subgraph Models["📦 Models"]
        GM["GameMode"]
        GS["GameSession"]
        QQ["QuizQuestion"]
        Card["Card"]
        TBT["TapButtonType"]
        DS["DifficultySnapshot"]
    end

    Views -->|"observes @Published state"| ViewModels
    Views -->|"reads / writes"| Services
    ViewModels -->|"reads / writes"| Services
    Services -->|"encodes / decodes"| Models
    ViewModels -->|"uses"| Models
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
│   │   │   ├── TapFrenzyMenuView.swift      # Round length selector
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
| Stats tab | Filter bar, unified overview HUD (games / best score / streak), scrollable bar chart, personal bests, recent games list |
| SwiftUI Charts | Horizontally scrollable `BarMark` chart showing score history per session |
| Map tab | Clean MapKit pins (POIs excluded) for every game location; tap for session detail callout |
| Settings tab | Daily notification toggle + time picker, data reset with confirmation dialog |
| ShareLink | Share score result on all three game over screens |
| Custom artwork | 3D clay-style matte game icons + cinematic background art in Home tiles and menus |
| Dark matte UI | Dark card backgrounds, clean borders, consistent accent colours per game |

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

When I started this project, I honestly did not expect it to grow this much. I just had to build a game app in SwiftUI. But week by week, one small feature led to another, and by the end I had three completely different games, a stats dashboard, a live map, notifications, and real internet data all working together inside one app.

The early weeks taught me how important it is to keep your state clean. Even something as simple as a tap counter becomes messy fast if you do not separate the logic from the UI. Once I started putting game logic inside ViewModels and letting the View just react to published state, everything became much easier to read and change. That habit carried through the whole project.

The hardest part was coordinating a grid, a timer, a lives system, and a difficulty curve all at the same time in Light It Up. I had to write an algorithm that changed how many cards appear, how long they stay lit, and which colours show up based on the player's score and then do a completely separate version of that for timed mode. Getting those two paths to share the same game logic without duplicating code took real thinking.

Networking in Quiz Rush was the moment MVVM finally clicked for me. The View does not need to know whether data is loading or failed. It just looks at the ViewModel's state and shows the right screen. That felt like a proper way to build something.

Week 4 surprised me the most. Connecting CoreLocation, MapKit, local notifications, SwiftUI Charts, and a shared data store all in one sprint was intense, but the reason it did not fall apart was because the previous weeks had already established clean boundaries between each part of the app.

The biggest lesson overall: architecture decisions made early pay off later. And also  making something actually feel good to use takes more iterations than you expect.
