import Cocoa
import FlutterMacOS
import ApplicationServices

@main
class AppDelegate: FlutterAppDelegate {
  private let macInputChannelName = "vibe_deck/macos_input"
  private var macInputChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    setupMacInputChannelIfNeeded()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(trySetupMacInputChannelFromWindowChange),
      name: NSWindow.didBecomeMainNotification,
      object: nil
    )
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @objc
  private func trySetupMacInputChannelFromWindowChange() {
    setupMacInputChannelIfNeeded()
  }

  private func setupMacInputChannelIfNeeded() {
    let controller = (mainFlutterWindow?.contentViewController as? FlutterViewController)
      ?? (NSApp.mainWindow?.contentViewController as? FlutterViewController)
      ?? NSApp.windows.compactMap { $0.contentViewController as? FlutterViewController }.first
    guard let controller else {
      return
    }
    registerMacInputChannelIfNeeded(with: controller)
  }

  func registerMacInputChannelIfNeeded(with controller: FlutterViewController) {
    if macInputChannel != nil {
      return
    }

    let channel = FlutterMethodChannel(
      name: macInputChannelName,
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(["ok": false, "error": "App delegate deallocated"])
        return
      }
      guard call.method == "sendHotkey" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any] else {
        result(["ok": false, "error": "Invalid arguments"])
        return
      }
      result(self.handleSendHotkey(args: args))
    }
    macInputChannel = channel
    NotificationCenter.default.removeObserver(
      self,
      name: NSWindow.didBecomeMainNotification,
      object: nil
    )
  }

  private func handleSendHotkey(args: [String: Any]) -> [String: Any] {
    guard AXIsProcessTrusted() else {
      return ["ok": false, "error": "Accessibility permission is not granted for this app"]
    }

    guard let key = args["key"] as? String else {
      return ["ok": false, "error": "Missing key"]
    }
    let modifiers = (args["modifiers"] as? [String] ?? []).map { $0.uppercased() }
    guard let keyCode = macKeyCode(for: key.uppercased()) else {
      return ["ok": false, "error": "Unsupported macOS key: \(key)"]
    }

    let flags = macFlags(for: modifiers)
    guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
          let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
      return ["ok": false, "error": "Failed to create keyboard events"]
    }

    keyDown.flags = flags
    keyUp.flags = flags
    keyDown.post(tap: .cghidEventTap)
    keyUp.post(tap: .cghidEventTap)
    return ["ok": true]
  }

  private func macFlags(for modifiers: [String]) -> CGEventFlags {
    var flags: CGEventFlags = []
    for modifier in modifiers {
      switch modifier {
      case "CTRL":
        flags.insert(.maskControl)
      case "ALT":
        flags.insert(.maskAlternate)
      case "SHIFT":
        flags.insert(.maskShift)
      case "CMD":
        flags.insert(.maskCommand)
      default:
        continue
      }
    }
    return flags
  }

  private func macKeyCode(for key: String) -> CGKeyCode? {
    switch key {
    case "A": return 0
    case "S": return 1
    case "D": return 2
    case "F": return 3
    case "H": return 4
    case "G": return 5
    case "Z": return 6
    case "X": return 7
    case "C": return 8
    case "V": return 9
    case "B": return 11
    case "Q": return 12
    case "W": return 13
    case "E": return 14
    case "R": return 15
    case "Y": return 16
    case "T": return 17
    case "1": return 18
    case "2": return 19
    case "3": return 20
    case "4": return 21
    case "6": return 22
    case "5": return 23
    case "=": return 24
    case "9": return 25
    case "7": return 26
    case "-": return 27
    case "8": return 28
    case "0": return 29
    case "]": return 30
    case "O": return 31
    case "U": return 32
    case "[": return 33
    case "I": return 34
    case "P": return 35
    case "ENTER": return 36
    case "L": return 37
    case "J": return 38
    case "'": return 39
    case "K": return 40
    case ";": return 41
    case "\\": return 42
    case ",": return 43
    case "/": return 44
    case "N": return 45
    case "M": return 46
    case ".": return 47
    case "TAB": return 48
    case "SPACE": return 49
    case "`": return 50
    case "BACKSPACE": return 51
    case "ESC": return 53
    case "F1": return 122
    case "F2": return 120
    case "F3": return 99
    case "F4": return 118
    case "F5": return 96
    case "F6": return 97
    case "F7": return 98
    case "F8": return 100
    case "F9": return 101
    case "F10": return 109
    case "F11": return 103
    case "F12": return 111
    case "HOME": return 115
    case "PAGEUP": return 116
    case "DELETE": return 117
    case "END": return 119
    case "PAGEDOWN": return 121
    case "LEFT": return 123
    case "RIGHT": return 124
    case "DOWN": return 125
    case "UP": return 126
    default:
      return nil
    }
  }
}
