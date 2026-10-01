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

# Zeitzone Frankfurt/Berlin
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p \
    /home/radio/music \
    /home/radio/news

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# Alte Datei/Pipe entfernen und echte Named Pipe erzeugen.
RUN rm -f /home/radio/live.wav /home/radio/live.pipe && \
    mkfifo -m 666 /home/radio/live.pipe

CMD ["bash", "-c", "\
    echo '=== Radio Freies Eurasien: starting FFmpeg ==='; \
    \
    ffmpeg \
      -hide_banner \
      -loglevel warning \
      -re \
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
      'rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u' \
      & \
    FFMPEG_PID=$!; \
    \
    echo '=== Radio Freies Eurasien: starting Liquidsoap ==='; \
    liquidsoap /home/radio/script.liq & \
    LIQ_PID=$!; \
    \
    wait -n $FFMPEG_PID $LIQ_PID; \
    STATUS=$?; \
    \
    kill $FFMPEG_PID $LIQ_PID 2>/dev/null || true; \
    exit $STATUS \
"]
