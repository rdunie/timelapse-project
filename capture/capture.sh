#!/bin/sh

RTSP_URL="${RTSP_URL:-rtsp://your-camera-url}"
BASE_DIR="/timelapse"
SYMLINK="$BASE_DIR/current"

echo "[INFO] Starting capture script..."
echo "[INFO] RTSP_URL: $RTSP_URL"
echo "[INFO] Waiting for symlink: $SYMLINK"

# Wait for symlink to exist
while [ ! -L "$SYMLINK" ]; do 
    echo "[INFO] Symlink not found, waiting..."
    sleep 1
done

echo "[INFO] Symlink found."

# Find the last frame number to resume from
LAST_FRAME=$(ls -1 "$SYMLINK" | grep -E '^frame_[0-9]{8}\.jpg$' | sort -V | tail -n 1)
START_NUMBER=1
if [ -n "$LAST_FRAME" ]; then
  LAST_NUMBER=$(echo "$LAST_FRAME" | sed -e 's/frame_//' -e 's/\.jpg//' | sed 's/^0*//')
  if [ -n "$LAST_NUMBER" ]; then
    START_NUMBER=$((LAST_NUMBER + 1))
  fi
fi

echo "[INFO] Starting ffmpeg capture from frame number $START_NUMBER..."
ffmpeg -rtsp_transport tcp -i "$RTSP_URL" -vf fps=0.2 -start_number "$START_NUMBER" "$SYMLINK/frame_%08d.jpg"

echo "[INFO] ffmpeg process started. Frames will be saved to $SYMLINK"