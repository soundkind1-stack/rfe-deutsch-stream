FROM alpine:latest

# 1. Zeitzone auf Berlin setzen und benötigte Audio-Tools + Python installieren
RUN apk add --no-cache \
    tzdata \
    liquidsoap \
    ffmpeg \
    curl \
    python3 \
    && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone

# 2. Arbeitsverzeichnis im Server erstellen
WORKDIR /home/radio

# 3. Das Automations-Skript und die Ordnerstrukturen vorbereiten
RUN mkdir -p /home/radio/music /home/radio/news

# 4. Den Server dauerhaft auf Empfang schalten
CMD ["liquidsoap", "/home/radio/script.liq"]
