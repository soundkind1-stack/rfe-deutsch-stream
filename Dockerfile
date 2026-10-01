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
        bash && \
    rm -rf /var/lib/apt/lists/*

# Zeitzone Berlin
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

# Projektverzeichnisse
RUN mkdir -p \
    /home/radio/music \
    /home/radio/news

# Projektdateien kopieren
COPY . /home/radio/

# Linux-Zeilenenden sicherstellen
RUN dos2unix /home/radio/script.liq

# ============================================================
# START (Optimiert auf ressourcenschonendes 480p Web-Streaming)
# ============================================================

CMD ["bash", "-c", "\
    set -m; \
    \
    rm -f /home/radio/live.wav /home/radio/live.pipe; \
    mkfifo -m 666 /home/radio/live.pipe; \
    \
    rm -f /home/radio/music/.gitkeep /home/radio/news/.gitkeep; \
    \
    echo '=== RFE: Launching Fake Webserver on Port 10000 ==='; \
    python3 -m http.server 10000 & \
    \
    echo '=== RFE: starting Liquidsoap ==='; \
    liquidsoap /home/radio/script.liq > /tmp/liquidsoap.log 2>&1 & \
    LIQ_PID=$!; \
    echo \"=== RFE: Liquidsoap PID $LIQ_PID ===\"; \
    \
    echo '=== RFE: Waiting 4 Seconds for Audio-Buffer... ==='; \
    sleep 4; \
    \
    echo '=== RFE: starting FFmpeg (480p Lean-Stream) ==='; \
    ffmpeg \
      -hide_banner \
      -loglevel info \
      -loop 1 \
      -framerate 30 \
      -i /home/radio/background.png \
      -f s16le \
      -ar 44100 \
      -ac 2 \
      -i /home/radio/live.pipe \
      -vf 'scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p' \
      -c:v libx264 \
      -preset ultrafast \
      -tune zerolatency \
      -pix_fmt yuv420p \
      -r 30 \
      -g 60 \
      -keyint_min 60 \
      -sc_threshold 0 \
      -b:v 1000k \
      -maxrate 1000k \
      -bufsize 2000k \
      -c:a aac \
      -b:a 128k \
      -ar 44100 \
      -ac 2 \
      -f flv \
      \"rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u\" \
      > /tmp/ffmpeg.log 2>&1 & \
    FFMPEG_PID=$!; \
    echo \"=== RFE: FFmpeg PID $FFMPEG_PID ===\"; \
    \
    sleep 2; \
    \
    echo '=== RFE: Current Liquidsoap log ==='; \
    cat /tmp/liquidsoap.log || true; \
    \
    echo '=== RFE: Current FFmpeg log ==='; \
    cat /tmp/ffmpeg.log || true; \
    \
    wait -n $FFMPEG_PID $LIQ_PID; \
    STATUS=$?; \
    \
    echo \"=== RFE: process exited with status $STATUS ===\"; \
    \
    echo '=== RFE: final Liquidsoap log ==='; \
    cat /tmp/liquidsoap.log || true; \
    \
    echo '=== RFE: final FFmpeg log ==='; \
    cat /tmp/ffmpeg.log || true; \
    \
    kill $FFMPEG_PID $LIQ_PID 2>/dev/null || true; \
    exit $STATUS \
"]
