# Threadsバズ投稿ジェネレーター 配布ページ

購入者向けの配布ページ。GitHub Pagesで公開している。

**公開URL: https://shiochann.github.io/threads-buzz-generator/**

`room-e94b82`（SNS投稿コレクター）と同じ作りにしてある。

---

## 構成

```
index.html                 ページ本体（CSSも中に入っている）
download/
  threads-buzz-generator.zip         配布する拡張機能のZIP（固定名）
assets/
  icon/                    ファビコン（拡張のyellowアイコンから作成）
  img/ogp.png              リンクプレビュー画像（1200×630）
  ogp-source.html          ↑の元データ
robots.txt                 クロールは許可、検索避けはHTML側のnoindexで行う
.nojekyll                  GitHub PagesのJekyll処理を切る
update.sh                  新バージョンへの差し替え
make-ogp.sh                OGP画像の作り直し
```

## 配布ZIPについて

**ZIPの中身はフラット構成**（`manifest.json` や `icons/` がZIPの直下に入っている）。
解凍すると `threads-buzz-generator` というフォルダができ、その中に
ファイルが直接並ぶ。この**フォルダごと**「パッケージ化されていない拡張機能を読み込む」
で選ぶのが正しい手順。

**配布ファイル名にバージョンを入れないこと。**
以前 `threads-buzz-generator-1.1.0.zip` のようにバージョン付きで配布していたが、
更新で旧ファイルが消えると、ページをキャッシュしているブラウザが消えたURLを叩いて
「サイトでファイルを取得できませんでした」になる。固定名なら常に最新が落ちる。
バージョンはページの表記と、ZIP内の `manifest.json` で分かる。

過去に `threads-buzz-extension` という別名で案内していた時期があり、
「解凍してもそのフォルダが無い」という問い合わせが出たので、
index.html の手順・FAQはこの実物の名前に合わせてある。
**バージョンを上げるときはZIPの中の構成を変えないこと。**

## 新しいバージョンを配布する

```bash
bash update.sh 1.2.0                     # ~/Downloads から拾う
bash update.sh 1.2.0 /path/to/some.zip   # パスを直接指定
git add -A && git commit -m "update: ver 1.2.0" && git push
```

`update.sh` はZIPの差し替えと、index.html のリンク・ver表記・サイズ表記の
書き換えまでやる。ZIPの直下に `manifest.json` が無い場合は警告が出る。

## リンクプレビュー画像を作り直す

```bash
bash make-ogp.sh
```

`assets/ogp-source.html` を編集してから実行する。
QuickLookが正方形でしか書き出せないので、1200×1200で作って中央630pxを切り出している。
**中央の帯からはみ出す位置に文字を置かないこと。**

## 検索避け

`index.html` の `<meta name="robots" content="noindex, nofollow, noarchive">` で行う。
robots.txt で `Disallow` にすると、そのnoindexを読んでもらえず逆効果になるので、
クロール自体は許可している。
