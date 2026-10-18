import AppKit

/// 最前面アプリの変化を監視し、入力ソースを自動で切り替える。
/// ターミナル/コードエディタ → 英数、それ以外 → そのアプリで最後に使っていた状態を復元。
final class AppContextSwitcher {
    static let eisuBundleIDs: Set<String> = [
        "com.apple.Terminal", "com.googlecode.iterm2", "dev.warp.Warp-Stable",
        "com.mitchellh.ghostty", "net.kovidgoyal.kitty", "org.alacritty",
        "com.microsoft.VSCode", "com.todesktop.230313mzl4w4u92", // VS Code / Cursor
        "com.apple.dt.Xcode", "com.jetbrains.intellij", "com.sublimetext.4",
        "dev.zed.Zed", "com.github.atom",
    ]

    var onSwitched: ((InputKind) -> Void)?

    private var lastState: [String: InputKind] = [:]
    private var currentApp: String?
    private var observer: NSObjectProtocol?

    func start() {
        guard observer == nil else { return }
        currentApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            self?.activated(app?.bundleIdentifier)
        }
    }

    func stop() {
        if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        observer = nil
    }

    private func activated(_ bundleID: String?) {
        // 離れるアプリの状態を記録
        if let prev = currentApp { lastState[prev] = InputSourceController.current() }
        currentApp = bundleID
        guard let bundleID, bundleID != Bundle.main.bundleIdentifier else { return }

        let target: InputKind? = Self.eisuBundleIDs.contains(bundleID) ? .eisu : lastState[bundleID]
        guard let target, target != InputSourceController.current() else { return }
        if InputSourceController.select(target) { onSwitched?(target) }
    }
}
