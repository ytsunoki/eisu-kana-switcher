# eisu-kana-switcher

左右 Command キーの単押しで英数/かなを切り替える macOS メニューバー常駐アプリ（Swift/SwiftUI、macOS 13+、App Sandbox 無効、外部ライブラリなし）。

## 詳細ドキュメント
- @docs/architecture.md — ソース構成と各ファイルの役割
- @docs/decisions.md — 設計上の決定と理由（削除した機能を含む）。**変更前に必読**
- @docs/release.md — テスト・署名・zip 作成・Release の手順
- `spec.md` — 要件。3章はロードマップ（未実装の候補）

## 守ること
- コミットの作者は `ytsunoki`（`24934468+ytsunoki@users.noreply.github.com`）。本名や実メールを履歴・ファイル・成果物に入れない
- 証明書・秘密鍵（`*.p12` 等）をコミットしない
- push・Release など外部への公開操作は、ユーザーに確認してから行う
- 開発の節目で適切にコミットし、戻せるようにする
- 仕様や決定を変えたら、この CLAUDE.md と docs/ も更新する

## テスト
`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project eisu-kana-switcher.xcodeproj -scheme eisu-kana-switcher -destination 'platform=macOS' CODE_SIGN_IDENTITY=- test`
