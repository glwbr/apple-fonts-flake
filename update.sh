#!/usr/bin/env sh

fonts=(
  "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg"
  "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg"
  "https://devimages-cdn.apple.com/design/resources/download/NY.dmg"
)

printf '{' >sources.nix

for url in "${fonts[@]}"; do
  font=$(basename "$url" .dmg | tr '[:upper:]' '[:lower:]')
  hash=$(nix hash to-sri --type sha256 $(nix-prefetch-url "$url"))
  printf '%s = { url = "%s"; hash = "%s"; };' "$font" "$url" "$hash" >>sources.nix
done

printf '}' >>sources.nix
