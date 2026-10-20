#!/usr/bin/env bash
set -euo pipefail

OWNER="fisbal"
REPO="alpha-omega"
ROOT="/home/claude/alpha-omega-repo"
WORK="/tmp/aorepo-push"
rm -rf "$WORK"
mkdir -p "$WORK"

cd "$ROOT"

# path:is_binary
FILES=(
  "app/index.html:text"
  "app/manifest.webmanifest:text"
  "app/sw.js:text"
  "app/icon-192.png:bin"
  "app/icon-512.png:bin"
  "app/icon-maskable-512.png:bin"
  "app/icon.ico:bin"
  "electron/package.json:text"
  "electron/main.js:text"
  "capacitor/package.json:text"
  "capacitor/capacitor.config.json:text"
  ".github/workflows/build.yml:text"
  "README.md:text"
  ".gitignore:text"
)

TREE_ENTRIES="$WORK/tree_entries.jsonl"
> "$TREE_ENTRIES"

for entry in "${FILES[@]}"; do
  path="${entry%%:*}"
  kind="${entry##*:}"
  echo "Blobbing $path ($kind)..." >&2

  if [ "$kind" = "bin" ]; then
    b64file="$WORK/$(echo "$path" | tr '/' '_').b64"
    base64 -w0 "$path" > "$b64file"
    sha=$(gh api "repos/$OWNER/$REPO/git/blobs" -F content=@"$b64file" -f encoding=base64 -q .sha)
  else
    sha=$(gh api "repos/$OWNER/$REPO/git/blobs" -F content=@"$path" -f encoding=utf-8 -q .sha)
  fi

  echo "  -> $sha"
  jq -n --arg path "$path" --arg sha "$sha" \
    '{path:$path, mode:"100644", type:"blob", sha:$sha}' >> "$TREE_ENTRIES"
done

jq -s '{tree: .}' "$TREE_ENTRIES" > "$WORK/tree_payload.json"

echo "Creating tree..." >&2
tree_sha=$(gh api "repos/$OWNER/$REPO/git/trees" --input "$WORK/tree_payload.json" -q .sha)
echo "tree sha: $tree_sha" >&2

jq -n --arg msg "Alpha & Omega: add Windows/Android/web auto-build pipeline (app content unchanged)" --arg tree "$tree_sha" \
  '{message:$msg, tree:$tree, parents: []}' > "$WORK/commit_payload.json"

echo "Creating commit..." >&2
commit_sha=$(gh api "repos/$OWNER/$REPO/git/commits" --input "$WORK/commit_payload.json" -q .sha)
echo "commit sha: $commit_sha" >&2

echo "Creating refs/heads/main..." >&2
jq -n --arg sha "$commit_sha" '{ref:"refs/heads/main", sha:$sha}' > "$WORK/ref_payload.json"
gh api "repos/$OWNER/$REPO/git/refs" --input "$WORK/ref_payload.json"

echo "DONE"
