# Vibe Deck Desktop App

Desktop host for Vibe Deck (`macOS`, `Windows`, `Linux`).

Project docs:
- English: [../README.md](../README.md)
- Русский: [../README.ru.md](../README.ru.md)

## What it does

- Starts WebSocket host on `ws://<host>:4040/ws`.
- Responds to LAN discovery probes on UDP `45454`.
- Handles secure pairing flow (`hello` challenge + pair code + session token).
- Executes button actions from mobile app:
  - `insert_text`
  - `hotkey`
  - `run_action` (allowlist-only)
- Provides runtime security toggles:
  - `allowTextInsert`
  - `allowHotkeys`
  - `allowActions`
  - `allowShellCommands`
- Stores and edits desktop action allowlist.
- Maintains and broadcasts deck profile (`deck_state`) to mobile client.

## Run

```sh
flutter pub get
flutter run -d macos
```

Use `-d windows` or `-d linux` for other desktop targets.

## Test

```sh
flutter test
```

## Main implementation files

- `lib/src/app_state.dart`
- `lib/src/server.dart`
- `lib/src/security.dart`
- `lib/src/executor.dart`
- `lib/src/discovery.dart`
