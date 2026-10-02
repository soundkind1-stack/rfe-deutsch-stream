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

# Zeitzone Berlin
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# ============================================================
# START (Vollständig bereinigt via XML-Struktur)
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
    \
    mkfifo -m 666 /home/radio/live.pipe; \
    \
    echo '=== RFE: FIFO created ==='; \
    echo '=== RFE: Rebuilding Playlist from Archive XML ==='; \
    python3 /home/radio/builder.py; \
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
    echo \"=== RFE: Liquidsoap PID $LIQ_PID ===\"; \
    sleep 5; \
    \
    echo '=== RFE: Starting FFmpeg ==='; \
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
      \"rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u\" \
      > /tmp/ffmpeg.log 2>&1 & \
    FFMPEG_PID=$!; \
    \
    wait $FFMPEG_PID; \
    kill $LIQ_PID 2>/dev/null || true; \
    exit 0 \
"]
