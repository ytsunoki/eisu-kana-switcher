import XCTest
@testable import en_kana_switch

/// 仕様 3, 4, 6: アプリ構成
final class AppConfigurationTests: XCTestCase {
    /// Dock アイコン非表示 (LSUIElement = YES)
    func testAgentApp() {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") as? Bool, true)
    }

    func testTerminalsAndEditorsForceEisu() {
        for id in ["com.apple.Terminal", "com.googlecode.iterm2", "com.microsoft.VSCode"] {
            XCTAssertTrue(AppContextSwitcher.eisuBundleIDs.contains(id), id)
        }
        XCTAssertFalse(AppContextSwitcher.eisuBundleIDs.contains("md.obsidian"))
    }

    /// TIS: 日本語入力ソースの判定
    func testCurrentInputSourceIsQueryable() {
        let kind = InputSourceController.current()
        XCTAssertTrue(kind == .eisu || kind == .kana)
    }
}
