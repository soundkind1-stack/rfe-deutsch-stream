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
# START
# ============================================================

CMD ["bash", "-c", "\
    set -m; \
    \
    rm -f /home/radio/live.wav /home/radio/live.pipe; \
    mkfifo -m 666 /home/radio/live.pipe; \
    \
    echo '=== RFE: FIFO created ==='; \
    \
    echo '=== RFE: starting FFmpeg ==='; \
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
      -vf 'scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p' \
      -c:v libx264 \
      -preset ultrafast \
      -tune zerolatency \
      -pix_fmt yuv420p \
      -r 30 \
      -g 60 \
      -keyint_min 60 \
      -sc_threshold 0 \
      -b:v 3000k \
      -maxrate 3000k \
      -bufsize 6000k \
      -c:a aac \
      -b:a 128k \
      -ar 44100 \
      -ac 2 \
      -f flv \
      \"$TWITCH_RTMP_URL\" \
      > /tmp/ffmpeg.log 2>&1 & \
    FFMPEG_PID=$!; \
    \
    echo \"=== RFE: FFmpeg PID $FFMPEG_PID ===\"; \
    \
    echo '=== RFE: starting Liquidsoap ==='; \
    liquidsoap /home/radio/script.liq & \
    LIQ_PID=$!; \
    \
    echo \"=== RFE: Liquidsoap PID $LIQ_PID ===\"; \
    \
    sleep 3; \
    \
    echo '=== RFE: Liquidsoap log ==='; \
    cat /tmp/liquidsoap.log || true; \
    \
    echo '=== RFE: FFmpeg log ==='; \
    cat /tmp/ffmpeg.log || true; \
    \
    echo '=== RFE: processes ==='; \
    ps -ef | grep -E 'ffmpeg|liquidsoap' | grep -v grep || true; \
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
