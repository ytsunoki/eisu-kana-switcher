import XCTest
@testable import eisu_kana_switcher

/// 仕様 2: モードA/B、仕様 4: 設定の永続化
final class SwitchModeTests: XCTestCase {
    func testModeAAbsolute() {
        for current in [InputKind.eisu, .kana] {
            XCTAssertEqual(SwitchMode.absolute.target(for: .left, current: current), .eisu)
            XCTAssertEqual(SwitchMode.absolute.target(for: .right, current: current), .kana)
        }
    }

    func testModeBToggle() {
        for side in [CommandTapDetector.Side.left, .right] {
            XCTAssertEqual(SwitchMode.toggle.target(for: side, current: .eisu), .kana)
            XCTAssertEqual(SwitchMode.toggle.target(for: side, current: .kana), .eisu)
        }
    }

    func testModeRawValuesStableForPersistence() {
        XCTAssertEqual(SwitchMode(rawValue: "absolute"), .absolute)
        XCTAssertEqual(SwitchMode(rawValue: "toggle"), .toggle)
        XCTAssertEqual(SwitchMode.allCases.count, 2)
    }

    func testModeSurvivesUserDefaultsRoundTrip() {
        let suite = UserDefaults(suiteName: "eisu-kana-switcher.tests")!
        defer { suite.removePersistentDomain(forName: "eisu-kana-switcher.tests") }
        suite.set(SwitchMode.toggle.rawValue, forKey: SettingsKey.mode)
        let reloaded = UserDefaults(suiteName: "eisu-kana-switcher.tests")!
        XCTAssertEqual(SwitchMode(rawValue: reloaded.string(forKey: SettingsKey.mode) ?? ""), .toggle)
    }
}
