import XCTest
@testable import en_kana_switch

/// 仕様 2: Command 単押し判定
final class CommandTapDetectorTests: XCTestCase {
    private var d = CommandTapDetector()

    override func setUp() { d = CommandTapDetector() }

    func testLeftTapFires() {
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: true))
        XCTAssertEqual(d.commandChanged(.left, anyCommandDown: false), .left)
    }

    func testRightTapFires() {
        XCTAssertNil(d.commandChanged(.right, anyCommandDown: true))
        XCTAssertEqual(d.commandChanged(.right, anyCommandDown: false), .right)
    }

    /// Cmd+C のように他のキーが押された場合は修飾キーとして扱い、発火しない
    func testKeyDownBetweenPressAndReleaseCancels() {
        _ = d.commandChanged(.left, anyCommandDown: true)
        d.otherInput()
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: false))
    }

    /// Cmd+クリック・Cmd+スクロールも同様 (KeyMonitor は otherInput を呼ぶ)
    func testOtherInputCancelsForRightToo() {
        _ = d.commandChanged(.right, anyCommandDown: true)
        d.otherInput()
        XCTAssertNil(d.commandChanged(.right, anyCommandDown: false))
    }

    /// Cmd+Shift など他の修飾キーが絡んだ場合も発火しない
    func testOtherModifierCancels() {
        _ = d.commandChanged(.left, anyCommandDown: true)
        d.otherInput()
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: false))
    }

    /// 左右同時押しは単押しではない
    func testBothCommandsHeldDoesNotFire() {
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: true))
        XCTAssertNil(d.commandChanged(.right, anyCommandDown: true))
        XCTAssertNil(d.commandChanged(.right, anyCommandDown: true))   // 右を離す(左は押下中)
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: false))
    }

    /// 他のキー操作後、次の単押しは再び有効になる
    func testTapWorksAgainAfterCancelledPress() {
        _ = d.commandChanged(.left, anyCommandDown: true)
        d.otherInput()
        _ = d.commandChanged(.left, anyCommandDown: false)
        _ = d.commandChanged(.left, anyCommandDown: true)
        XCTAssertEqual(d.commandChanged(.left, anyCommandDown: false), .left)
    }

    func testConsecutiveTapsEachFire() {
        for side in [CommandTapDetector.Side.left, .right, .left] {
            _ = d.commandChanged(side, anyCommandDown: true)
            XCTAssertEqual(d.commandChanged(side, anyCommandDown: false), side)
        }
    }

    func testResetClearsPending() {
        _ = d.commandChanged(.left, anyCommandDown: true)
        d.reset()
        XCTAssertNil(d.commandChanged(.left, anyCommandDown: false))
    }
}
