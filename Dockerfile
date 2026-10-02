FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# System-Pakete installieren (inklusive TrueType-Schriftarten für die Laufschrift)
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

# Zeitzone Berlin festnageln
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music /home/radio/news

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

# ============================================================
# START (Reiner Textbefehl ohne fehleranfällige eckige Klammern)
# ============================================================

CMD set -m; \
    rm -f /home/radio/live.wav /home/radio/live.pipe; \
    mkfifo -m 666 /home/radio/live.pipe; \
    rm -f /home/radio/music/.gitkeep /home/radio/news/.gitkeep; \
    \
    python3 -m http.server 10000 & \
    bash -c 'while true; do sleep 60; curl -s -I http://localhost:10000 > /dev/null; done' & \
    \
    echo '=== RFE: Initializing Finanzen.net Data Fetcher ==='; \
    python3 -c " \
import urllib.request, re, time \
def fetch_ticker(): \
    try: \
        req = urllib.request.Request('https://finanzen.net', headers={'User-Agent': 'Mozilla/5.0'}) \
        with urllib.request.urlopen(req) as response: html = response.read().decode('utf-8') \
        titles = re.findall(r'<title><\!\[CDATA\[(.*?)\]\]></title>', html) \
        feed_text = ' +++ '.join([t for t in titles if 'finanzen.net' not in t]) \
        with urllib.request.urlopen('https://coindesk.com') as btc_resp: \
            btc_data = btc_resp.read().decode('utf-8') \
            btc_price = re.search(r'\"rate\":\"(.*?)\"', btc_data).group(1).split('.')[0] \
        ticker = f'+++ RADIO FREIES EURASIEN WIRTSCHAFTSTICKER +++ BITCOIN: ${btc_price} +++ FINANZEN.NET: {feed_text} +++ ' \
        with open('/tmp/ticker.txt', 'w') as f: f.write(ticker * 2) \
    except Exception as e: \
        with open('/tmp/ticker.txt', 'w') as f: f.write('+++ RFE WIRTSCHAFTSTICKER: Lade Marktdaten... +++ ') \
fetch_ticker() \
" && \
    \
    bash -c "while true; do \
        sleep 300; \
        python3 -c \" \
import urllib.request, re \
try: \
    req = urllib.request.Request('https://finanzen.net', headers={'User-Agent': 'Mozilla/5.0'}) \
    with urllib.request.urlopen(req) as response: html = response.read().decode('utf-8') \
    titles = re.findall(r'<title><\!\[CDATA\[(.*?)\]\]></title>', html) \
    feed_text = ' +++ '.join([t for t in titles if 'finanzen.net' not in t]) \
    with urllib.request.urlopen('https://coindesk.com') as btc_resp: \
        btc_data = btc_resp.read().decode('utf-8') \
        btc_price = re.search(r'\"rate\":\"(.*?)\"', btc_data).group(1).split('.')[0] \
    ticker = f'+++ RADIO FREIES EURASIEN WIRTSCHAFTSTICKER +++ BITCOIN: ${btc_price} +++ FINANZEN.NET: {feed_text} +++ ' \
    with open('/tmp/ticker.txt', 'w') as f: f.write(ticker * 2) \
except: pass \
\" ; done" & \
    \
    liquidsoap /home/radio/script.liq > /tmp/liquidsoap.log 2>&1 & \
    LIQ_PID=$!; \
    sleep 4; \
    \
    echo '=== RFE: starting FFmpeg with Moving Text Overlay ==='; \
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
      -vf "scale=854:480,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:textfile=/tmp/ticker.txt:y=h-30:x=854-mod(t*40\,1500):fontcolor=white:fontsize=18:box=1:boxcolor=black@0.6:boxborderw=6,format=yuv420p" \
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
      "rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u" \
      > /tmp/ffmpeg.log 2>&1 & \
    FFMPEG_PID=$!; \
    \
    wait -n $FFMPEG_PID $LIQ_PID; \
    STATUS=$?; \
    kill $FFMPEG_PID $LIQ_PID 2>/dev/null || true; \
    exit $STATUS
