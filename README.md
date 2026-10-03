# SarmaxStream Flutter

Native Android Flutter client for SarmaxStream. This Stage 1 build implements music search and playback without WebView, Expo, React Native, or YouTube audio extraction.

## Requirements

Flutter stable 3.47 or newer, Android SDK / Android Studio, and an Android device or emulator.

## API base URL

The app defaults to:

```text
https://sarmaxstreams.vercel.app
```

The default is compiled into the app, so plain `flutter run` and the CI build use it automatically. You can still override it for another environment with `--dart-define`:

```sh
flutter run --dart-define=API_BASE_URL=https://sarmaxstreams.vercel.app
```

Replace the value only when targeting a different deployed origin. Do not put server API keys in the app.

## Run on a phone

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release APK locally

```sh
flutter build apk --release
```

The APK is produced at `build/app/outputs/flutter-apk/app-release.apk`. Flutter's default Android configuration signs this local release build with the debug key, which is suitable for installing on a test phone but not for publishing to an app store.

## GitHub Actions APK

The workflow at `.github/workflows/build-apk.yml` runs on every push and can also be started manually. It installs Java 17 and the latest stable Flutter, then runs `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.

To download the APK:

1. Open the repository on GitHub and select the **Actions** tab.
2. Select **Build Android APK** and open a successful workflow run.
3. Scroll to **Artifacts** and download **sarmaxstream-apk**.
4. Unzip the downloaded artifact and install `app-release.apk` on an Android phone. Android may ask you to allow installation from that download source.

The CI APK uses the same default API base URL above. The workflow does not receive or embed server API keys.

## Signing a release build

Create an upload key outside the repository:

```sh
keytool -genkeypair -v -keystore ~/sarmax-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias sarmax
```

Then create `android/key.properties` (it is git-ignored; the Gradle config already reads it):

```text
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=sarmax
storeFile=/absolute/path/to/sarmax-upload-keystore.jks
```

Without that file the release build falls back to the debug key, which is fine for your own phone but not for publishing. Never commit the keystore or passwords.

For GitHub Actions, add these repository secrets and the workflow signs the APK for you: `ANDROID_KEYSTORE_BASE64` (base64 of the .jks file), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.

## Security notes

- The API base URL must be `https://`; the app refuses to start with anything else.
- Android blocks all cleartext (http) traffic, disables backup/device-transfer of app data, and trusts only system certificates (debug builds additionally allow http to `localhost` / `10.0.2.2`).
- Server data is validated before use: YouTube ids must be exactly 11 safe characters, artwork must be https, resolve responses are type-checked.
- Release builds are obfuscated and never write errors or stack traces to the device log.
- No API keys or secrets are stored in the app.

## Phone testing

Follow [TEST_CHECKLIST.md](TEST_CHECKLIST.md) for Stage 1 playback, lock-screen, offline, source-fallback, safe track switching, and queue-restoration checks.

## Movies, TV and YouTube

The app now has four tabs: **Home**, **Movies** (movies and TV shows: browse, search, details, cast, trailers), **YouTube** (trending and search, played in YouTube's own player) and **Music**.

All data comes through your SarmaxStream server, so the app holds no keys. Two small server routes are needed (`api/tmdb.js` and `api/youtube.js`, shipped separately in the backend additions folder). The app expects them at `/api/tmdb` and `/api/youtube` on the same API base URL as music.

Full-length films are not played inside the app; each title page offers its trailer instead.

The look (colors, wordmark, launcher icon) matches the website.
