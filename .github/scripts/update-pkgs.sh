#!/usr/bin/env bash
# Checks each package in pkgs/ (excluding pkgs/python/) for a newer upstream
# release and rewrites its version/hash in place.
#
# Prints one "<pname> <old> -> <new>" line per updated package to stdout.
# Requires: bash, curl, jq, nix. Set GH_TOKEN to avoid GitHub API rate limits.
set -euo pipefail

cd "$(dirname "$0")/../../pkgs"

log() { echo "$@" >&2; }

# Reads the value of `<attr> = "...";` from a .nix file (first match).
get_attr() {
  sed -nE "s/^[[:space:]]*$2 = \"([^\"]*)\";.*/\1/p" "$1" | head -n1
}

# Replaces `<attr> = "<old>";` with `<attr> = "<new>";` in a .nix file.
set_attr() {
  local file=$1 attr=$2 new=$3 tmp
  tmp=$(mktemp)
  sed -E "s|^([[:space:]]*$attr = )\"[^\"]*\";|\1\"$new\";|" "$file" >"$tmp"
  mv "$tmp" "$file"
}

# Replaces the literal string <old> with <new> in a .nix file.
replace() {
  local file=$1 old=$2 new=$3 tmp
  tmp=$(mktemp)
  sed "s|$old|$new|" "$file" >"$tmp"
  mv "$tmp" "$file"
}

# Downloads <url> into the Nix store and prints its SRI sha256 hash.
prefetch() {
  local hash
  hash=$(nix store prefetch-file --json --hash-type sha256 "$1" | jq -r .hash) || return 1
  [[ $hash == sha256-* ]] || return 1
  echo "$hash"
}

github_latest_tag() {
  curl -fsSL ${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} \
    "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

# Updates a single-hash package whose URL is derived from `version`.
update_simple() {
  local file=$1 pname=$2 latest=$3 url=$4 current
  current=$(get_attr "$file" version)
  if [[ -z $latest || $latest == null ]]; then
    log "$pname: could not determine latest version, skipping"
    return
  fi
  if [[ $current == "$latest" ]]; then
    log "$pname: $current is up to date"
    return
  fi
  log "$pname: $current -> $latest"
  local hash
  hash=$(prefetch "$url") || return 1
  set_attr "$file" hash "$hash"
  set_attr "$file" version "$latest"
  echo "$pname $current -> $latest"
}

update_muro() {
  local v
  v=$(github_latest_tag MrRockySL/Muro)
  v=${v#v}
  update_simple muro.nix muro "$v" \
    "https://github.com/MrRockySL/Muro/releases/download/v$v/Muro-$v.dmg"
}

update_harbor() {
  local v
  v=$(github_latest_tag thsnkhn/harbor)
  v=${v#v}
  update_simple harbor.nix harbor "$v" \
    "https://github.com/thsnkhn/harbor/releases/download/v$v/Harbor-$v.dmg"
}

update_clipbeam() {
  local v
  v=$(curl -fsSL https://clipbeam.com/ |
    grep -oE 'Clipbeam_[0-9][0-9.]*[0-9]\.dmg' |
    sed -E 's/Clipbeam_(.*)\.dmg/\1/' | sort -V | tail -n1)
  update_simple clipbeam.nix clipbeam "$v" \
    "https://clipbeam.ams3.digitaloceanspaces.com/Clipbeam_$v.dmg"
}

update_bettertouchtool() {
  local file=bettertouchtool.nix cask current build latest latest_build url
  cask=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/homebrew-cask/HEAD/Casks/b/bettertouchtool.rb)
  # Cask version looks like: version "6.861,2026092506"
  read -r latest latest_build < <(
    sed -nE 's/^[[:space:]]*version "([^,]+),([^"]+)".*/\1 \2/p' <<<"$cask"
  )
  current=$(get_attr "$file" version)
  build=$(get_attr "$file" build)
  if [[ -z ${latest:-} || -z ${latest_build:-} ]]; then
    log "bettertouchtool: could not determine latest version, skipping"
    return
  fi
  if [[ $current == "$latest" && $build == "$latest_build" ]]; then
    log "bettertouchtool: $current is up to date"
    return
  fi
  log "bettertouchtool: $current ($build) -> $latest ($latest_build)"
  url="https://folivora.ai/releases/btt$latest-$latest_build.zip"
  local hash
  hash=$(prefetch "$url") || return 1
  set_attr "$file" hash "$hash"
  set_attr "$file" version "$latest"
  set_attr "$file" build "$latest_build"
  echo "bettertouchtool $current -> $latest"
}

update_texpile() {
  local file=texpile.nix current latest old_hashes
  current=$(get_attr "$file" version)
  latest=$(curl -fsSL https://dl.texpile.com/latest.json | jq -r .version)
  if [[ -z $latest || $latest == null ]]; then
    log "texpile: could not determine latest version, skipping"
    return
  fi
  if [[ $current == "$latest" ]]; then
    log "texpile: $current is up to date"
    return
  fi
  log "texpile: $current -> $latest"
  # Two hashes (dmg, then AppImage), in file order.
  mapfile -t old_hashes < <(sed -nE 's/^[[:space:]]*hash = "([^"]*)";.*/\1/p' "$file")
  local base="https://dl.texpile.com/v$latest" dmg_hash appimage_hash
  dmg_hash=$(prefetch "$base/Texpile-$latest.dmg") || return 1
  appimage_hash=$(prefetch "$base/Texpile-$latest.AppImage") || return 1
  replace "$file" "${old_hashes[0]}" "$dmg_hash"
  replace "$file" "${old_hashes[1]}" "$appimage_hash"
  set_attr "$file" version "$latest"
  echo "texpile $current -> $latest"
}

# Lingon Pro is published at a fixed URL, so the only signal is a hash change.
# The version can't be read from upstream; bump it manually if needed.
update_lingon_pro() {
  local file=lingon-pro.nix current new url
  url=$(get_attr "$file" url)
  current=$(get_attr "$file" hash)
  new=$(prefetch "$url") || return 1
  if [[ $current == "$new" ]]; then
    log "lingon-pro: hash unchanged"
    return
  fi
  log "lingon-pro: hash changed"
  set_attr "$file" hash "$new"
  echo "lingon-pro: new build at $url"
}

status=0
for pkg in muro harbor clipbeam bettertouchtool texpile lingon_pro; do
  if ! "update_$pkg"; then
    log "${pkg//_/-}: update check failed"
    status=1
  fi
done
exit $status
