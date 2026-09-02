#!/bin/bash
# リンクプレビュー用画像（OGP, 1200×630）を作る。
#   使い方: bash make-ogp.sh
#
# 仕組み:
#   QuickLook(qlmanage)はHTMLを正方形で書き出すので、
#   assets/ogp-source.html を1200×1200で作り、中央の630pxだけをsipsで切り出す。
#   Chromeのヘッドレスは環境によってハングするため使っていない。
set -e
cd "$(dirname "$0")"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

qlmanage -t -s 1200 -o "$TMP" assets/ogp-source.html >/dev/null 2>&1

SRC="$TMP/ogp-source.html.png"
if [ ! -f "$SRC" ]; then
  echo "画像を書き出せませんでした" >&2
  exit 1
fi

# 念のため1200×1200に揃えてから、中央の1200×630を切り出す
sips -z 1200 1200 "$SRC" >/dev/null
sips -c 630 1200 "$SRC" --out assets/img/ogp.png >/dev/null

echo "作成しました: assets/img/ogp.png"
sips -g pixelWidth -g pixelHeight assets/img/ogp.png | tail -2
