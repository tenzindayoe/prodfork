# MacEvents iOS App

Comprehensive SwiftUI client for browsing, saving, and previewing Macalester College events. Built for Xcode 16.2 and the iPhone 16 Pro Max simulator, it fetches live data from the MacEvents backend API.

> **Prerequisites**
> - macOS with Xcode 16.2+
> - iPhone 16 Pro Max simulator (or physical device with matching target)
> - MacEvents server running; see server repo README for setup

---

## Project Structure

```
MacEvents/                # App sources, assets, configuration
├── Assets.xcassets       # Image catalog for venues, logos, etc.
├── Event.swift           # Event model + image helpers
├── EventService.swift    # Network abstraction + `RemoteEventService`
├── EventFeedViewModel.swift
│                         # ObservableObject powering home screen sections
├── EventHome.swift       # Main “Home” tab (Today/Tomorrow/Upcoming)
├── EventRowView.swift    # Shared row UI reused by multiple lists
├── EventDetail.swift     # Full detail page with description/map
├── LikedEventsView.swift # “Liked” tab with saved future events
├── LikedStore.swift      # Observable store persisting liked IDs
├── LocationMap.swift     # MapKit-based view for event coordinates
├── MacEventsApp.swift    # App entry point + dependency wiring
├── RootView.swift        # Tab layout (Home / Liked / Settings placeholder)
├── SettingsView.swift    # Placeholder for future settings
└── ... (widgets, previews, Info.plist, entitlements)

MacEventsTests/           # Unit tests using `swift-testing`
└── ...                   # View-model, store, and view logic tests

MacEventsUITests/         # UI test target scaffold (XCTest)

MacEvents.xcodeproj/      # Xcode project/workspace metadata
```

---

## Source File Guide

### Core Models & Services

- **`Event.swift`** – Codable/Comparable event model. Provides:
  - `formatDate()` to convert the server date string into `Date` objects.
  - `widgetImage` / `circleImage` helpers that pick assets based on location keywords.
  - Comparable conformance lets you sort events chronologically across the app.
- **`EventService.swift`** – Protocol-first networking.
  - `EventService` defines an async `fetchEvents()` contract for easy mocking.
  - `RemoteEventService` implements the live API call (configurable URL/session).
  - Tests inject their own service implementations for deterministic data.
- **`LikedStore.swift`** – Lightweight persisted store for favorite IDs.
  - `@Published var ids: Set<String>` automatically writes to `UserDefaults` whenever it changes.
  - `toggle`, `contains`, and `remove` power the heart buttons throughout the UI.

### View Models

- **`EventFeedViewModel.swift`** – Shared state for the home feed.
  - Fetches events via dependency-injected `EventService`.
  - Exposes loading/error state plus `Sections` struct grouping Today, Tomorrow, Upcoming.
  - Pure logic (calendar grouping) makes it unit-test friendly.

### Views

- **`MacEventsApp.swift`** – App entry; hosts `RootView` and supplies `LikedStore` via `environmentObject`.
- **`RootView.swift`** – Defines the `TabView` with Home and Liked tabs (plus optional placeholders).
- **`EventHome.swift`** – Main screen.
  - Uses `EventFeedViewModel` for data and displays sections inside a `List` to avoid layout overflow.
  - Supports pull-to-refresh and a reload toolbar button.
  - Navigates into `EventDetail` using `EventRowView` rows.
- **`EventRowView.swift`** – Shared row component.
  - Shows image, title, time/date/location, and heart button bound to `LikedStore`.
  - Consumed by both Home sections and the Liked tab for consistent UI/tests.
- **`LikedEventsView.swift`** – Saved items list.
  - Fetches the same event feed through `EventService` but filters by liked IDs and future dates.
  - Presents loaders, error states, and swipe-to-remove actions.
- **`EventDetail.swift`** – Detailed info page.
  - Displays description, location, optional map via `LocationMap`, and allows liking.
- **`EventWidget.swift` & `HomePageColumn.swift`** – Legacy card-style UI components (currently unused after the home refactor) but still available for experiments.
- **`LocationMap.swift`** – Wraps MapKit to show event coordinates if provided.
- **`SettingsView.swift`** – Placeholder view (expand with real preferences later).

### Assets & Config

- **`Assets.xcassets`** – Venue photos, logos, accent colors.
- **`Config.json`** – Optional config that maps location keywords to specific image asset names, used by `Event.setImage`.
- **`Info.plist` / `MacEvents.entitlements`** – Standard bundle configuration; update if adding capabilities.

### Tests

- **`MacEventsTests/LikedStoreTests.swift`** – Ensures toggling, persistence, and removal behave as expected.
- **`MacEventsTests/LikedEventsViewTests.swift`** – Validates filtering logic for liked/upcoming lists.
- **`MacEventsTests/EventFeedViewModelTests.swift`** – Covers the new view-model’s loading success path and its Today/Tomorrow/Future grouping using `MockEventService`.
- **`MacEventsTests/MacEventsTests.swift`** – Template for additional cases.
- **`MacEventsUITests/...`** – Launch test scaffold; extend with UI regressions as needed.

---

## Running the App

1. Start the MacEvents backend service (see backend README) so the API endpoint returns data.
2. Open `MacEvents.xcodeproj` in Xcode 16.2.
3. Select the *MacEvents* scheme and the *iPhone 16 Pro Max* simulator.
4. Build & run (`Cmd+R`).
5. Use the Home tab to browse events; tap hearts to like, and find saved items in the Liked tab.

> Tip: Pull down on Home or Liked lists to trigger the refresh logic that re-fetches events.

---

## Testing

- Unit tests rely on the new dependency-injected services and view models.
- Run all unit/UI tests from Xcode: `Product > Test` (`Cmd+U`).
- `EventFeedViewModelTests` provide a template for writing more mock-driven tests; inject a custom `EventService` anywhere to avoid hitting the network.

---

## Extending the App

- **Add new tabs** by updating `RootView` and supplying the required environment objects.
- **New API endpoints**: conform to `EventService` to keep networking centralized and testable.
- **Additional filters/sorting**: extend `EventFeedViewModel.Sections` or add new computed properties so the UI stays declarative.
- **Settings or notifications**: integrate via `SettingsView` or new services; keep side effects outside SwiftUI views when possible (e.g., in the app object or dedicated managers).

This README should serve as a map for onboarding contributors—refer to the file-level descriptions above when navigating the codebase or planning refactors.
