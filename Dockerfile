FROM ubuntu:22.04

# 1. Interaktive Abfragen blockieren und System-Pakete updaten
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tzdata \
    liquidsoap \
    ffmpeg \
    curl \
    python3 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. Zeitzone auf Europa/Berlin festnageln
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

# 3. Arbeitsverzeichnisse im Server erstellen
WORKDIR /home/radio

RUN mkdir -p /home/radio/music /home/radio/news

# 4. Den Server auf Empfang schalten und Skript starten
CMD ["liquidsoap", "/home/radio/script.liq"]
