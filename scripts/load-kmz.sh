#!/bin/bash
set -euo pipefail

# Define paths
TMP_DIR="/tmp/kmz_work"
KMZ_FILE="/docker-entrypoint-initdb.d/data/SEPTARegionalRailStations2016.kmz"
EXTRACTED_KML="$TMP_DIR/kmz_extracted/doc.kml"
GEOJSON_FILE="$TMP_DIR/stations.geojson"

# Cleanup function to remove temp files
cleanup() {
  echo "🧹 Cleaning up temp files..."
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Prepare temp workspace
mkdir -p "$TMP_DIR/kmz_extracted"

echo "🗂️ Unzipping KMZ..."
unzip -o "$KMZ_FILE" -d "$TMP_DIR/kmz_extracted/"

echo "🔁 Converting KML to GeoJSON..."
ogr2ogr -f "GeoJSON" "$GEOJSON_FILE" "$EXTRACTED_KML"

echo "🗄️ Importing into PostGIS..."
ogr2ogr \
  -f "PostgreSQL" \
  PG:"host=/var/run/postgresql user=samuel dbname=septa_db password=secret123" \
  "$GEOJSON_FILE" \
  -nln stations \
  -lco GEOMETRY_NAME=geom \
  -nlt PROMOTE_TO_MULTI \
  -overwrite

echo "✅ Import complete!"