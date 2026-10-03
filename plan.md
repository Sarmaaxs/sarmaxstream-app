# SarmaxStream Flutter Stage 1 Plan

## Scope
Implement Stage 1 (Music) as a real native Flutter Android app. No WebView, Expo, React Native, or website UI reuse. The app calls only the existing HTTPS API and uses public Supabase values only when later account work is added.

## Design
- **Movement:** dark, cinematic music-player interface with restrained glass surfaces and lime signal accents.
- **Core principles:** immediate search, clear playback state, one-handed controls, friendly offline/error states.
- **Palette:** `#08080A` background, `#D4FF1A` lime primary, muted graphite surfaces, warm white text.
- **Layout:** edge-to-edge vertical content with compact bottom navigation and a persistent mini-player above it.
- **Signature elements:** lime progress line, rounded charcoal cards, album art with soft glow.
- **Interaction:** tap a result to resolve/play; playback never silently resumes while resolution is pending; queue and state persist locally.
- **Animation:** short fades and scale transitions; no distracting motion during loading.
- **Typography:** Material system sans for controls; strong high-contrast titles.
- **Brand essence:** a focused home for music discovery and uninterrupted listening. Personality: direct, nocturnal, energetic.

## Dependencies (`pubspec.yaml`)
- `dio` — HTTPS API client and timeout handling
- `flutter_riverpod` — application state and dependency injection
- `go_router` — navigation
- `just_audio` — foreground audio playback
- `audio_service` — background playback, media notification, lock-screen controls
- `audio_session` — Android audio focus and headset interruptions
- `shared_preferences` — search/resolve/state cache
- `cached_network_image` — album artwork loading
- `intl` — compact duration formatting

## Folder tree
```text
lib/
├── main.dart
├── core/
│   ├── api/api_client.dart
│   ├── cache/local_store.dart
│   └── theme/app_theme.dart
└── features/music/
    ├── application/music_controller.dart
    ├── data/music_api.dart
    ├── data/music_audio_handler.dart
    ├── domain/track.dart
    └── presentation/music_home_page.dart
```

## Stage 1 behavior
- Debounced music search with 10-minute cache and stale-while-refresh behavior.
- Catalog IDs (`dz_`/`it_`) resolve through `/api/resolve`; Audius/Jamendo stream through `/api/stream`.
- Free-stream failure retries `/api/resolve?skip=free` once and falls back to YouTube only as a foreground embedded-player placeholder message; this Stage 1 build does not download or extract YouTube audio.
- Queue, current track, position, volume, shuffle and repeat persist locally.
- Background notification/lock-screen controls are wired for direct audio URLs.
- Friendly errors and an offline-aware cached-results experience.
