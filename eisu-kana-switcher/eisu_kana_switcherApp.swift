import SwiftUI
import ApplicationServices
import Combine

/// アクセシビリティ権限の状態。変化をメニュー表示に反映するため Observable にする。
final class PermissionState: ObservableObject {
    static let shared = PermissionState()
    @Published var trusted = AXIsProcessTrusted()
    func refresh() { trusted = AXIsProcessTrusted() }
}

@main
struct eisu_kana_switcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @AppStorage(SettingsKey.mode) private var mode = SwitchMode.absolute.rawValue
    @AppStorage(SettingsKey.enabled) private var enabled = true
    @ObservedObject private var permission = PermissionState.shared

    var body: some Scene {
        MenuBarExtra("英数/かな切り替え", systemImage: "keyboard") {
            Toggle("有効", isOn: $enabled)
            Divider()
            Picker("切り替えモード", selection: $mode) {
                ForEach(SwitchMode.allCases) { Text($0.title).tag($0.rawValue) }
            }
            .pickerStyle(.inline)
            Divider()
            if !permission.trusted {
                Button("アクセシビリティ権限を許可…") { AppDelegate.requestAccessibility() }
            }
            Button("終了") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = KeyMonitor()
    private var retryTimer: Timer?

    static func requestAccessibility() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor.onTap = { [weak self] side in self?.handleTap(side) }
        defer { PermissionState.shared.refresh() }
        if !monitor.start() {
            // 権限が無い場合は許可を促し、付与されるまで再試行する
            Self.requestAccessibility()
            retryTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
                guard let self, self.monitor.start() else { return }
                PermissionState.shared.refresh()
                t.invalidate()
                self.retryTimer = nil
            }
        }
    }

    private func handleTap(_ side: KeyMonitor.Side) {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: SettingsKey.enabled) as? Bool ?? true else { return }
        let mode = SwitchMode(rawValue: defaults.string(forKey: SettingsKey.mode) ?? "") ?? .absolute

        let target = mode.target(for: side, current: InputSourceController.current())
        InputSourceController.select(target)
    }
}
