#!/bin/bash
# 配布ファイルを新しいバージョンに差し替える。
#
#   使い方:  bash update.sh 1.2.0
#            bash update.sh 1.2.0 ~/Desktop/threads-buzz-generator-1.2.0.zip
#
# やること:
#   1. 指定バージョンのZIPをdownload/にコピー
#   2. 古いZIPを削除
#   3. index.html のダウンロードリンク・バージョン表記・サイズを書き換え
#
# このあと git push すれば公開される。
set -e
cd "$(dirname "$0")"

VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "バージョンを指定してください  例) bash update.sh 1.2.0" >&2
  exit 1
fi

SRC="${2:-$HOME/Downloads/threads-buzz-generator-${VERSION}.zip}"
if [ ! -f "$SRC" ]; then
  echo "ZIPが見つかりません: $SRC" >&2
  echo "第2引数でZIPのパスを直接指定することもできます。" >&2
  exit 1
fi

# 配布ファイル名はバージョンを含めない固定名にしている。
# バージョン付きにすると、ページがブラウザにキャッシュされている人が
# 消えた旧ファイルを叩いて「サイトでファイルを取得できませんでした」になるため。
# バージョンはページの表記と、ZIP内の manifest.json で分かる。
DEST="download/threads-buzz-generator.zip"
cp "$SRC" "$DEST"

SIZE_KB=$(( ($(stat -f%z "$DEST") + 512) / 1024 ))

# ZIPの中身がフォルダ1枚に入っていないか（＝説明文と食い違わないか）を確認する。
# この配布ZIPは manifest.json が直下にある「フラット構成」が正しい。
if ! unzip -l "$DEST" | grep -qE ' manifest\.json$'; then
  echo "⚠️  ZIPの直下に manifest.json がありません。" >&2
  echo "    index.html の手順（フォルダをそのまま選ぶ）と食い違うので確認してください。" >&2
fi

# ZIP内のバージョンが指定と一致しているか確認する（manifest.jsonの上げ忘れ防止）
ZIP_VER=$(unzip -p "$DEST" manifest.json | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
if [ "$ZIP_VER" != "$VERSION" ]; then
  echo "⚠️  manifest.json のバージョンが ${ZIP_VER} です（指定は ${VERSION}）。" >&2
  echo "    拡張側の manifest.json を上げ忘れていないか確認してください。" >&2
fi

# バージョン表記 / サイズ を差し替え（リンク先は固定名なので触らない）
python3 - "$VERSION" "$SIZE_KB" <<'PY'
import re, sys
version, size = sys.argv[1], sys.argv[2]
p = "index.html"
html = open(p, encoding="utf-8").read()

html = re.sub(r'(<span class="dl-badge">)ver [^<]+(</span>)',
              rf'\g<1>ver {version}\g<2>', html)
html = re.sub(r'(<span class="dl-badge neutral">)約\d+KB(</span>)',
              rf'\g<1>約{size}KB\g<2>', html)

open(p, "w", encoding="utf-8").write(html)
print(f"  index.html を ver {version} / 約{size}KB に更新しました")
PY

echo
echo "差し替え完了: ver ${VERSION}"
echo
echo "残りの手順:"
echo "  git add -A && git commit -m \"update: ver ${VERSION}\" && git push"
