# Vibe Deck Mobile App

Mobile controller for Vibe Deck (`iOS`, `Android`).

Project docs:
- English: [../README.md](../README.md)
- Русский: [../README.ru.md](../README.ru.md)

## What it does

- Discovers desktop hosts on local network (UDP + WebSocket probe fallback).
- Connects to desktop host by IP/host and port.
- Performs pairing using pair code and `hello` challenge flow.
- Stores active session token and sends:
  - `trigger` requests for deck buttons
  - `health_ping` checks
- Receives `deck_state` and applies latest profile version.
- Renders configurable deck grid (up to 24 buttons) with mandatory locked `Enter` button.

## Run

```sh
flutter pub get
flutter run -d ios
```

Use `-d android` for Android.

## Test

```sh
flutter test
```

## Main implementation files

- `lib/src/app_state.dart`
- `lib/src/data/ws_client.dart`
- `lib/src/data/discovery_service.dart`
- `lib/src/models/deck_models.dart`
