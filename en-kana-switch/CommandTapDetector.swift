/// Command キーの「単押し(タップ)」を判定する純粋なステートマシン。
/// CGEvent に依存しないので単体テストできる。
struct CommandTapDetector {
    enum Side { case left, right }

    private var leftHeld = false
    private var rightHeld = false
    private var pending: Side?  // 押下中で、まだ単押しの可能性があるキー

    /// 左右 Command キーの flagsChanged。`anyCommandDown` は event.flags の Command ビット。
    /// 単押しが完了した場合にその Side を返す。
    mutating func commandChanged(_ side: Side, anyCommandDown: Bool) -> Side? {
        // Command が全て離されているのに状態が残っていたら同期をとり直す
        if !anyCommandDown {
            let tapped = pending == side && isHeld(side)
            leftHeld = false
            rightHeld = false
            pending = nil
            return tapped ? side : nil
        }
        if isHeld(side) {
            // 片方を離した(もう片方は押下中)
            set(side, false)
            pending = nil
        } else {
            set(side, true)
            // 他の Command が押されたままなら単押しではない
            pending = (leftHeld != rightHeld) ? side : nil
        }
        return nil
    }

    /// 他のキー・マウス操作・他の修飾キー = Command は修飾キーとして使われている
    mutating func otherInput() { pending = nil }

    mutating func reset() {
        leftHeld = false
        rightHeld = false
        pending = nil
    }

    private func isHeld(_ side: Side) -> Bool { side == .left ? leftHeld : rightHeld }

    private mutating func set(_ side: Side, _ held: Bool) {
        if side == .left { leftHeld = held } else { rightHeld = held }
    }
}
