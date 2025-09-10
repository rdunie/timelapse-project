#!/bin/sh

BASE_DIR="/timelapse"
VIDEO_DIR="$BASE_DIR/videos"
SYMLINK="$BASE_DIR/current"
echo "[INFO] Creating video directory: $VIDEO_DIR"
mkdir -p "$VIDEO_DIR"

# Recover or Initial setup
if [ -L "$SYMLINK" ]; then
  echo "[INFO] Symlink found, recovering active directory."
  ACTIVE_DIR=$(readlink "$SYMLINK")
  echo "[INFO] Recovered active directory: $ACTIVE_DIR"
else
  echo "[INFO] Symlink not found. Creating initial frames directory."
  ACTIVE_DIR="$BASE_DIR/frames_$(date +"%Y%m%d_%H%M%S")"
  mkdir -p "$ACTIVE_DIR"
  echo "[INFO] Creating symlink: $SYMLINK -> $ACTIVE_DIR"
  ln -sfn "$ACTIVE_DIR" "$SYMLINK"
fi


echo "[INFO] Rotator started. Entering main loop."
while true; do
  echo "[INFO] Sleeping for 12 hours."
  sleep 43200  # Wait 12 hours

  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  NEW_DIR="$BASE_DIR/frames_$TIMESTAMP"

  echo "[INFO] Creating new frames directory: $NEW_DIR"
  mkdir -p "$NEW_DIR"
  echo "[INFO] Updating symlink: $SYMLINK -> $NEW_DIR"
  ln -sfn "$NEW_DIR" "$SYMLINK"

  # Check if ACTIVE_DIR has frames before creating video
  if [ -n "$(ls -A "$ACTIVE_DIR" 2>/dev/null)" ]; then
    echo "[INFO] Creating timelapse video: $VIDEO_DIR/timelapse_$TIMESTAMP.mp4"
    ffmpeg -framerate 15 -pattern_type glob -i "$ACTIVE_DIR/*.jpg" \
      -c:v libx264 -pix_fmt yuv420p "$VIDEO_DIR/timelapse_$TIMESTAMP.mp4"
  else
    echo "[INFO] No frames found in $ACTIVE_DIR, skipping video creation."
  fi

  echo "[INFO] Removing old frames directory: $ACTIVE_DIR"
  rm -r "$ACTIVE_DIR"
  ACTIVE_DIR="$NEW_DIR"
done
