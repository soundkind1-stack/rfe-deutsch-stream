my_music = playlist("/home/radio/music")
security = single("/usr/share/sound/test.wav")
radio = fallback(track_sensitive=false, [my_music, security])

# Absolut abwärtskompatibler Video-Ausgang für Version 2.0.2
output.url(
  url="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  %ffmpeg(
    format="flv",
    vcodec="libx264",
    acodec="aac",
    vsetting=[
      ("vf", "movie=/home/radio/background.png [img]; [in][img] overlay=0:0 [out]")
    ]
  ),
  radio
)
