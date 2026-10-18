import AppKit
import CoreGraphics

/// CGEventTap で Command キーの「単押し(タップ)」を検出する。
/// Cmd を押している間に他のキー/マウス操作があれば単押しとはみなさない。
final class KeyMonitor {
    enum Side { case left, right }

    var onTap: ((Side) -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?

    // 左右 Command のキーコード
    private let leftCmd: Int64 = 0x37
    private let rightCmd: Int64 = 0x36

    private var pending: Side?       // 押下中で、まだ単押しの可能性があるキー
    private var cmdDownCount = 0     // 押下中の Command キー数

    var isRunning: Bool { tap != nil }

    @discardableResult
    func start() -> Bool {
        guard tap == nil else { return true }
        let mask: CGEventMask =
            (1 << CGEventType.flagsChanged.rawValue)
            | (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.rightMouseDown.rawValue)
            | (1 << CGEventType.otherMouseDown.rawValue)
            | (1 << CGEventType.scrollWheel.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let monitor = Unmanaged<KeyMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            monitor.handle(type: type, event: event)
            return Unmanaged.passUnretained(event)  // イベントは常にそのまま通す
        }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return false }
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = src
        return true
    }

    func stop() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        tap = nil
        source = nil
        reset()
    }

    private func reset() {
        pending = nil
        cmdDownCount = 0
    }

    private func handle(type: CGEventType, event: CGEvent) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            reset()
        case .flagsChanged:
            handleFlags(event)
        default:
            // 他のキー・マウス操作 = Cmd は修飾キーとして使われている
            pending = nil
        }
    }

    private func handleFlags(_ event: CGEvent) {
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        guard code == leftCmd || code == rightCmd else {
            // Shift 等、他の修飾キーの変化も単押しを無効化する
            pending = nil
            return
        }
        let side: Side = code == leftCmd ? .left : .right

        // Command が全て離されているのに状態が残っていたら同期をとり直す
        if !event.flags.contains(.maskCommand) {
            let tapped = pending == side && (side == .left ? leftHeld : rightHeld)
            leftHeld = false
            rightHeld = false
            cmdDownCount = 0
            pending = nil
            if tapped { onTap?(side) }
            return
        }

        if side == .left ? leftHeld : rightHeld {
            // 片方を離した(もう片方は押下中)
            setHeld(side, false)
            pending = nil
        } else {
            setHeld(side, true)
            // 他の Command が押されたままなら単押しではない
            pending = cmdDownCount == 1 ? side : nil
        }
    }

    private var leftHeld = false
    private var rightHeld = false

    private func setHeld(_ side: Side, _ held: Bool) {
        switch side {
        case .left: leftHeld = held
        case .right: rightHeld = held
        }
        cmdDownCount = (leftHeld ? 1 : 0) + (rightHeld ? 1 : 0)
    }
}
