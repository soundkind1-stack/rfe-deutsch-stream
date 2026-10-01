FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Multimedia-Tools und den Icecast-Audioserver installieren
RUN apt-get update && apt-get install -y \
    tzdata \
    liquidsoap \
    ffmpeg \
    icecast2 \
    curl \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music /home/radio/news

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# ==============================================================================
# 2. DER SYSTEM-TRICK: Erst Icecast starten, dann Liquidsoap, dann mixt FFmpeg das Video!
# ==============================================================================
CMD icecast2 -b -c /etc/icecast2/icecast.xml && \
    liquidsoap --detach /home/radio/script.liq && \
    sleep 3 && \
    ffmpeg -re -loop 1 -i /home/radio/background.png -i http://localhost:8000/radio.mp3 -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1500k -c:a copy -f flv rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u
