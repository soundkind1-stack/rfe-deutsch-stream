my_music = playlist("/home/radio/music")
security = single("/usr/share/sound/test.wav")
radio = fallback(track_sensitive=false, [my_music, security])

# Das ist der exakte, fehlerfreie Befehl für die Version 2.0.2!
video_stream = single.video("/home/radio/background.png")
rfe_broadcast = mux.video(video=video_stream, radio)

output.url(
  url="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  %ffmpeg(format="flv", vcodec="libx264", acodec="aac"),
  rfe_broadcast
)
