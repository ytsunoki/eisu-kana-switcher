import Foundation

enum SwitchMode: String, CaseIterable, Identifiable {
    case absolute  // モードA: 左Cmd=英数, 右Cmd=かな
    case toggle    // モードB: 左右Cmd=トグル

    var id: String { rawValue }

    var title: String {
        switch self {
        case .absolute: return "モードA: 左⌘=英数 / 右⌘=かな"
        case .toggle: return "モードB: ⌘でトグル"
        }
    }
}

extension SwitchMode {
    /// Command 単押し時に切り替える先の入力ソース。
    func target(for side: CommandTapDetector.Side, current: InputKind) -> InputKind {
        switch self {
        case .absolute: return side == .left ? .eisu : .kana
        case .toggle: return current == .eisu ? .kana : .eisu
        }
    }
}

enum SettingsKey {
    static let mode = "switchMode"
    static let enabled = "switchEnabled"
}
