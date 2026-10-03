# SarmaxStream Stage 1 Phone Test Checklist

Use a real Android phone with a network connection. The checklist is for the Stage 1 music build. Record the phone model, Android version, app build, API site, and date before testing.

## Search

- [ ] Launch the app with a normal network connection.
- [ ] Search for a known song and artist.
- [ ] Confirm results show artwork, title, artist, and duration.
- [ ] Type quickly and confirm the app does not issue a visible request for every keystroke.
- [ ] Repeat the same search within 10 minutes and confirm cached results appear promptly.

## Playback sources

- [ ] Select a song known to resolve to Audius. Confirm the resolve spinner appears, then confirm playback starts.
- [ ] Lock the phone while the Audius song is playing. Confirm audio continues with the screen off.
- [ ] Use the lock-screen notification to pause, resume, seek if available, skip next, and skip previous.
- [ ] Select a catalog song that does not have an Audius/Jamendo stream and falls back to YouTube. Confirm the app clearly says it is foreground-only and does not pretend that background audio is available.
- [ ] Confirm no YouTube audio is downloaded or extracted.

## Switching tracks safely

- [ ] Start one song and wait until it is audible.
- [ ] Select a different catalog song while the first is playing.
- [ ] Confirm the old song stops immediately and never resumes while the new song is resolving.
- [ ] Confirm the new song either starts or shows a friendly failure message.

## Background and lock screen

- [ ] Start a playable Audius/Jamendo track.
- [ ] Press the phone power button to turn the screen off.
- [ ] Confirm playback continues for at least two minutes.
- [ ] Use headset/Bluetooth play and pause controls if available.
- [ ] Confirm notification controls remain available and reflect the current playing state.

## Airplane mode and offline behavior

- [ ] With search results already loaded, enable airplane mode.
- [ ] Repeat the same search and confirm cached results are shown when available.
- [ ] Try a search that has never been cached and confirm a friendly offline message appears; raw Dio/HTTP errors must not be shown.
- [ ] While offline, attempt to resolve a new catalog song and confirm playback fails clearly without resuming the previous track.
- [ ] Disable airplane mode and confirm a new search works again.

## Queue restoration

- [ ] Search for several tracks and start one so the queue contains multiple entries.
- [ ] Close the app normally, then reopen it.
- [ ] Confirm the saved current track and queue are present or restorable.
- [ ] Confirm the app does not unexpectedly begin playing the previous track without a user action.
- [ ] Press play and confirm playback resumes from the saved queue/current-track state when the source is available.

## Result notes

- Device/model:
- Android version:
- App commit or artifact:
- API base URL:
- Passed checks:
- Failed checks and logs:

## Movies, TV and YouTube

- [ ] Home shows a trending hero, the three shortcuts, "Trending now", "Popular movies" and "Trending on YouTube"; pull down to refresh.
- [ ] Movies tab: rows load; Movies / TV shows switch works; searching shows a poster grid; clearing the search returns to the rows.
- [ ] Open a title: backdrop, genres, runtime, overview, cast and "More like this" appear; "Watch trailer" plays and fullscreen works.
- [ ] YouTube tab: trending list loads; searching returns results; a video plays and fullscreen works.
- [ ] Start a song, then open a video or trailer: the song pauses.
- [ ] Back button on any non-Home tab returns to Home; on Home it leaves the app.
- [ ] Airplane mode: each screen shows "Try again" instead of crashing; Try again works when back online.
- [ ] Logo on the launch screen, Settings and the app icon is the sarmaxstream wordmark.
