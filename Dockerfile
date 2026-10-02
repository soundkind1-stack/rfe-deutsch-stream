FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        tzdata \
        liquidsoap \
        ffmpeg \
        curl \
        dos2unix \
        coreutils \
        python3 \
        fonts-dejavu-core \
        bash && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# ZEITZONE
# ============================================================
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

# ============================================================
# ARBEITSVERZEICHNIS
# ============================================================
WORKDIR /home/radio

RUN mkdir -p /home/radio/music

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# ============================================================
# START (Optimiert & Korrigiert via Render Environment Variables)
# ============================================================
CMD ["bash", "-c", "\
    set -m; \
    \
    echo '================================================'; \
    echo ' RFE - RADIO FREIES EURASIEN'; \
    echo ' Container startup'; \
    echo '================================================'; \
    \
    rm -f /home/radio/live.wav; \
    rm -f /home/radio/live.pipe; \
    rm -f /home/radio/playlist.txt; \
    rm -f /home/radio/playlist_raw.txt; \
    \
    mkfifo -m 666 /home/radio/live.pipe; \
    \
    echo '=== RFE: FIFO created ==='; \
    \
    echo '=== RFE: Downloading real Archive.org M3U ==='; \
    \
    if [ -z \"$ARCHIVE_M3U_URL\" ]; then \
        echo 'ERROR: ARCHIVE_M3U_URL is not configured!'; \
        exit 10; \
    fi; \
    \
    curl \
      -fL \
      --retry 5 \
      --retry-delay 5 \
      --connect-timeout 15 \
      --max-time 120 \
      -A 'Mozilla/5.0 RFE-Radio/1.0' \
      \"$ARCHIVE_M3U_URL\" \
      -o /home/radio/playlist_raw.txt; \
    \
    CURL_STATUS=$?; \
    \
    if [ $CURL_STATUS -ne 0 ]; then \
        echo 'ERROR: Archive.org M3U could not be downloaded.'; \
        echo \"curl exit code: $CURL_STATUS\"; \
        exit 11; \
    fi; \
    \
    echo '=== RFE: M3U downloaded successfully ==='; \
    echo '=== RFE: First lines of M3U ==='; \
    head -20 /home/radio/playlist_raw.txt; \
    \
    echo '=== RFE: Converting M3U entries to absolute URLs ==='; \
    \
    python3 -c \" \
import urllib.parse; \
m3u_url = '$ARCHIVE_M3U_URL'; \
out = '/home/radio/playlist.txt'; \
count = 0; \
with open('/home/radio/playlist_raw.txt', 'r', encoding='utf-8', errors='ignore') as src, open(out, 'w', encoding='utf-8') as dst: \
    for line in src: \
        line = line.strip(); \
        if not line or line.startswith('#'): \
            continue; \
        url = urllib.parse.urljoin(m3u_url, line); \
        dst.write(url + '\\\\n'); \
        count += 1; \
print('=== RFE: Generated', count, 'audio URLs ==='); \
\"; \
    \
    echo '=== RFE: Generated playlist ==='; \
    cat /home/radio/playlist.txt; \
    \
    if [ ! -s /home/radio/playlist.txt ]; then \
        echo 'ERROR: playlist.txt is empty!'; \
        exit 12; \
    fi; \
    \
    echo '=== RFE: Generating Financial Ticker ==='; \
    python3 /home/radio/ticker.py; \
    \
    echo '=== RFE: Starting Liquidsoap ==='; \
    liquidsoap /home/radio/script.liq > /tmp/liquidsoap.log 2>&1 & \
    LIQ_PID=$!; \
    \
    echo \"=== RFE: Liquidsoap PID $LIQ_PID ===\"; \
    \
    sleep 5; \
    \
    echo '=== RFE: Liquidsoap startup log ==='; \
    cat /tmp/liquidsoap.log || true; \
    \
    echo '=== RFE: Starting FFmpeg ==='; \
    \
    ffmpeg \
      -hide_banner \
      -loglevel info \
      -loop 1 \
      -framerate 1 \
      -i /home/radio/background.png \
      -f s16le \
      -ar 44100 \
      -ac 2 \
      -i /home/radio/live.pipe \
      -vf \"scale=854:480,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:textfile=/tmp/ticker.txt:y=h-30:x=(w-tw)/2:fontcolor=white:fontsize=16:box=1:boxcolor=black@0.7:boxborderw=8,format=yuv420p\" \
      -c:v libx264 \
      -preset ultrafast \
      -tune zerolatency \
      -pix_fmt yuv420p \
      -r 1 \
      -g 2 \
      -keyint_min 2 \
      -sc_threshold 0 \
      -b:v 300k \
      -maxrate 300k \
      -bufsize 600k \
      -c:a aac \
      -b:a 128k \
      -ar 44100 \
      -ac 2 \
      -f flv \
      \"$TWITCH_RTMP_URL\" \
      > /tmp/ffmpeg.log 2>&1 & \
    \
    FFMPEG_PID=$!; \
    \
    echo \"=== RFE: FFmpeg PID $FFMPEG_PID ===\"; \
    \
    wait $FFMPEG_PID; \
    STATUS=$?; \
    \
    echo \"=== RFE: FFmpeg exited with status $STATUS ===\"; \
    \
    echo '=== RFE: Liquidsoap log ==='; \
    cat /tmp/liquidsoap.log || true; \
    \
    echo '=== RFE: FFmpeg log ==='; \
    cat /tmp/ffmpeg.log || true; \
    \
    kill $LIQ_PID 2>/dev/null || true; \
    \
    exit $STATUS \
"]
