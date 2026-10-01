FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Systempakete installieren
RUN apt-get update && apt-get install -y \
    tzdata \
    liquidsoap \
    ffmpeg \
    curl \
    python3 \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# 2. Zeitzone einstellen
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

# 3. Arbeitsverzeichnis erstellen
WORKDIR /home/radio

# 4. Ordner für die Musik anlegen
RUN mkdir -p /home/radio/music /home/radio/news

# ==============================================================================
# 5. DER ENTSCHEIDENDE FIX: Alle Dateien von GitHub direkt in den Server kopieren!
# ==============================================================================
COPY . /home/radio/

# 6. Ordnerinhalte an die richtige Stelle verschieben, falls du sie im Hauptverzeichnis hochgeladen hast
RUN cp -r /home/radio/music/* /home/radio/music/ 2>/dev/null || true
RUN cp -r /home/radio/news/* /home/radio/news/ 2>/dev/null || true

# 7. Unsichtbare Störzeichen aus dem Skript rasieren
RUN dos2unix /home/radio/script.liq

# 8. Startbefehl ausführen
CMD ["liquidsoap", "/home/radio/script.liq"]
