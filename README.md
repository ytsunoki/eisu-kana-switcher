# eisu-kana-switcher

US配列キーボード（HHKB など）向けの、軽量な macOS メニューバー常駐ユーティリティです。
**Command キーの単押し**で、入力ソースを「英数」「かな」に切り替えます。設定不要で動きます。

## 機能

切り替えモードはメニューバーのアイコンから選べます。

| モード | 動作 |
|---|---|
| **モードA（絶対指定）** | 左 ⌘ 単押し → 英数 / 右 ⌘ 単押し → かな |
| **モードB（トグル）** | 左右どちらの ⌘ でも、単押しで英数 ⇔ かなを交互に切り替え |

- `⌘C` など他のキーとの同時押しは、通常の Command キーとして動作します（単独で押して離したときだけ切り替わります）。
- 設定（モード・有効/無効）はアプリを再起動しても保持されます。
- Dock アイコンは表示されません。

## 動作環境

- macOS 13 以降
- 入力ソースに「ABC（または US）」と「日本語（ひらがな）」を追加しておいてください。

## インストール

1. [Releases](../../releases) から最新の `eisu-kana-switcher.zip` をダウンロードして展開します。
2. `eisu-kana-switcher.app` を `/Applications` に移動して起動します。
3. 署名・公証していないビルドの場合、初回は「開発元を検証できません」と表示されます。
   `.app` を右クリック →「開く」を選ぶか、ターミナルで次を実行してください。

   ```sh
   xattr -cr /Applications/eisu-kana-switcher.app
   ```

## 権限（アクセシビリティ）

Command キーの押下を検出するため、**アクセシビリティ**の許可が必要です。

1. 初回起動時に表示されるダイアログから「システム設定を開く」を選びます。
2. 「プライバシーとセキュリティ → アクセシビリティ」で `eisu-kana-switcher` をオンにします。

許可すると、そのまま切り替えが有効になります（再起動は不要です）。
権限が無い間は、メニューに「アクセシビリティ権限を許可…」と表示されます。

## プライバシー

- 監視しているのは Command キーの押下・解放と、「単押し」判定のためのキー・マウス操作の発生**有無**だけです。
- 入力した文字の内容は読み取らず、記録も保存もしません。
- ネットワーク通信は一切行いません。
- キーイベントは変更せずそのまま通します。

## ビルド

Xcode 26 以降で `eisu-kana-switcher.xcodeproj` を開いて Run するか、コマンドラインで実行します。

```sh
xcodebuild -project eisu-kana-switcher.xcodeproj -scheme eisu-kana-switcher build
```

テスト:

```sh
xcodebuild -project eisu-kana-switcher.xcodeproj -scheme eisu-kana-switcher \
  -destination 'platform=macOS' CODE_SIGN_IDENTITY=- test
```

CGEventTap を使うため、App Sandbox は無効です（Mac App Store では配布できません）。

## 仕様

[spec.md](spec.md) を参照してください。

## ライセンス

[MIT](LICENSE)
