import Carbon

enum InputKind {
    case eisu  // 英数 (ABC/US)
    case kana  // かな (日本語)
}

/// TIS API で入力ソースの取得・変更を行う。
enum InputSourceController {
    private static func sources(_ filter: [CFString: Any]) -> [TISInputSource] {
        let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue()
        return (list as? [TISInputSource]) ?? []
    }

    private static func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let ptr = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private static func languages(_ source: TISInputSource) -> [String] {
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) else { return [] }
        return (Unmanaged<CFArray>.fromOpaque(ptr).takeUnretainedValue() as? [String]) ?? []
    }

    static func isJapanese(_ source: TISInputSource) -> Bool {
        if let id = stringProperty(source, kTISPropertyInputSourceID), id.hasPrefix("com.apple.inputmethod.Kotoeri") {
            return true
        }
        return languages(source).contains("ja")
    }

    static func current() -> InputKind {
        let src = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        return isJapanese(src) ? .kana : .eisu
    }

    @discardableResult
    static func select(_ kind: InputKind) -> Bool {
        let candidates = sources([
            kTISPropertyInputSourceIsSelectCapable: true,
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
        ])
        let target: TISInputSource?
        switch kind {
        case .eisu:
            let ascii = candidates.filter { !isJapanese($0) && isASCIICapable($0) }
            target = ascii.first { stringProperty($0, kTISPropertyInputSourceID) == "com.apple.keylayout.ABC" }
                ?? ascii.first { stringProperty($0, kTISPropertyInputSourceID) == "com.apple.keylayout.US" }
                ?? ascii.first
        case .kana:
            target = candidates.first { isJapanese($0) }
        }
        guard let target else { return false }
        return TISSelectInputSource(target) == noErr
    }

    private static func isASCIICapable(_ source: TISInputSource) -> Bool {
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsASCIICapable) else { return false }
        return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(ptr).takeUnretainedValue())
    }
}
