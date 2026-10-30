import AppKit
import CoreGraphics

/// CGEventTap で Command キーの「単押し(タップ)」を検出する。
/// Cmd を押している間に他のキー/マウス操作があれば単押しとはみなさない。
final class KeyMonitor {
    typealias Side = CommandTapDetector.Side

    var onTap: ((Side) -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?

    // 左右 Command のキーコード
    private let leftCmd: Int64 = 0x37
    private let rightCmd: Int64 = 0x36

    private var detector = CommandTapDetector()

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
            options: .defaultTap,  // アクセシビリティ権限で動作。イベントは変更せず通す
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

    private func reset() { detector.reset() }

    private func handle(type: CGEventType, event: CGEvent) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            reset()
        case .flagsChanged:
            handleFlags(event)
        default:
            detector.otherInput()
        }
    }

    private func handleFlags(_ event: CGEvent) {
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        guard code == leftCmd || code == rightCmd else {
            detector.otherInput()  // Shift 等、他の修飾キーの変化
            return
        }
        let side: Side = code == leftCmd ? .left : .right
        if let tapped = detector.commandChanged(side, anyCommandDown: event.flags.contains(.maskCommand)) {
            onTap?(tapped)
        }
    }
}
