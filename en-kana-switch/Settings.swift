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

enum SettingsKey {
    static let mode = "switchMode"
    static let enabled = "switchEnabled"
}
