FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Nur die stabilen Kern-Pakete installieren (Kein Icecast mehr!)
RUN apt-get update && apt-get install -y \
    tzdata \
    liquidsoap \
    ffmpeg \
    curl \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music /home/radio/news

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# 2. Die Audiopuffer-Datei als virtuelle Pipe initialisieren
RUN touch /home/radio/live.wav

# 3. Liquidsoap als Hintergrund-Daemon (-d) starten und FFmpeg das Video zu Twitch streamen lassen!
CMD liquidsoap -d /home/radio/script.liq && \
    sleep 2 && \
    ffmpeg -re -loop 1 -i /home/radio/background.png -i /home/radio/live.wav -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1500k -c:a aac -b:a 128k -f flv rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u
