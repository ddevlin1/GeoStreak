#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/GeoStreak/Resources/countries.geojson"
URL="https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson"
echo "Downloading public-domain Natural Earth country boundaries..."
curl -L --fail "$URL" -o "$OUT"
echo "Saved: $OUT"
