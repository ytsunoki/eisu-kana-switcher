# アーキテクチャ

ソースは `eisu-kana-switcher/` にある。

| ファイル | 役割 |
|---|---|
| `CommandTapDetector.swift` | ⌘単押しの判定を行う純粋なステートマシン（`commandChanged` / `otherInput` / `reset`）。副作用なし |
| `KeyMonitor.swift` | `CGEventTap`（`.defaultTap`）でキーイベントを監視し、`CommandTapDetector` に渡す。イベントは常にそのまま通す |
| `InputSourceController.swift` | TIS API で入力ソースの取得・切り替え（`isJapanese` / `current` / `select`） |
| `Settings.swift` | `SwitchMode`（absolute / toggle）、`target(for:current:)`、`SettingsKey` |
| `eisu_kana_switcherApp.swift` | `MenuBarExtra` の UI、`PermissionState`（権限状態）、`AppDelegate`（監視開始・権限要求・1秒ごとの再試行・`handleTap`） |
| `AppIcon.icon` | Icon Composer 形式のアイコン（Liquid Glass 対応） |

## 切り替えモード
- absolute: 左⌘=英数、右⌘=かな
- toggle: どちらの⌘でも現在の入力ソースをトグル

## テスト
`eisu-kana-switcherTests/`（XCTest、ホストアプリ型）。判定ロジックと設定を対象にしている。キー監視と TIS は実機確認が必要。
