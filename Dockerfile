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

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

WORKDIR /home/radio

RUN mkdir -p /home/radio/music

COPY . /home/radio/

RUN dos2unix /home/radio/script.liq

EXPOSE 10000

CMD ["bash", "-c", "\
rm -f /home/radio/live.pipe && \
mkfifo -m 666 /home/radio/live.pipe && \
python3 -m http.server 10000 --bind 0.0.0.0 --directory /home/radio > /tmp/http.log 2>&1 & \
liquidsoap /home/radio/script.liq > /tmp/liquidsoap.log 2>&1 & \
sleep 4 && \
ffmpeg \
-re \
-thread_queue_size 2048 \
-loop 1 \
-framerate 2 \
-i /home/radio/background.png \
-thread_queue_size 2048 \
-f s16le \
-ar 44100 \
-ac 2 \
-i /home/radio/live.pipe \
-vf \"scale=854:480,format=yuv420p\" \
-c:v libx264 \
-preset ultrafast \
-tune zerolatency \
-pix_fmt yuv420p \
-r 2 \
-g 4 \
-b:v 150k \
-maxrate 150k \
-bufsize 300k \
-c:a aac \
-b:a 64k \
-ar 44100 \
-ac 2 \
-f tee \
-map 0:v -map 1:a \
\"[f=flv]rtmp://a.rtmp.youtube.com/live2/2t99-w0zu-mku7-6m0y-8qch|[f=flv]rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u\" \
"]
