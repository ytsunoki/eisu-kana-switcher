# リリース手順

## 署名
- 自己署名証明書 `eisu-kana-switcher Dev`（ログインキーチェーン、コード署名）を使う。要件が証明書ハッシュに固定され、更新しても許可が維持される。
- 秘密鍵は Mac のキーチェーンにのみ置く。リポジトリや Release に上げない。
- 署名を変えると、利用者はアクセシビリティの許可をやり直す必要がある。未公証なので、初回は右クリック→開く、または `xattr -cr` が必要。

## zip の作り方
1. `MARKETING_VERSION` を `project.pbxproj` で更新（4か所）。
2. 次のビルドを実行（**カバレッジを必ず無効化**。有効だとバイナリにローカルパスが入る）:
```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project eisu-kana-switcher.xcodeproj -scheme eisu-kana-switcher -configuration Release -destination 'generic/platform=macOS' ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="eisu-kana-switcher Dev" CLANG_COVERAGE_MAPPING=NO ENABLE_CODE_COVERAGE=NO DEPLOYMENT_POSTPROCESSING=YES STRIP_INSTALLED_PRODUCT=YES COPY_PHASE_STRIP=YES "OTHER_SWIFT_FLAGS=-file-prefix-map $PWD=. -file-prefix-map $HOME=~" -derivedDataPath build build
```
3. `ditto -c -k --keepParent build/Build/Products/Release/eisu-kana-switcher.app dist/eisu-kana-switcher.zip`
4. 検証: 展開して `codesign --verify --deep --strict`、`strings` で本名・ユーザー名・`/Users/` が含まれないことを確認。

## 公開
タグ `vX.Y.Z` を push し、`gh release create` で zip を添付（現状は pre-release）。説明文に SHA-256 を載せる。`dist/` と `build/` は `.gitignore` 済み。
