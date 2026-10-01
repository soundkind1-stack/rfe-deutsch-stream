FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# dos2unix wird mit installiert, um unsichtbare Windows-Zeichen zu killen
RUN apt-get update && apt-get install -y \
    tzdata \
    liquidsoap \
    ffmpeg \
    curl \
    python3 \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music /home/radio/news

# Bevor Liquidsoap startet, wäscht dieser Befehl die script.liq komplett rein!
CMD dos2unix /home/radio/script.liq && liquidsoap /home/radio/script.liq
