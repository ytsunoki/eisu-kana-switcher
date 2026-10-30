import XCTest
@testable import eisu_kana_switcher

/// 仕様 4, 5: アプリ構成
final class AppConfigurationTests: XCTestCase {
    /// Dock アイコン非表示 (LSUIElement = YES)
    func testAgentApp() {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") as? Bool, true)
    }

    /// TIS: 日本語入力ソースの判定
    func testCurrentInputSourceIsQueryable() {
        let kind = InputSourceController.current()
        XCTAssertTrue(kind == .eisu || kind == .kana)
    }
}
