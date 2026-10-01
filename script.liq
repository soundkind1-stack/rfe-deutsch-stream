my_music = playlist("/home/radio/music")
security = single("/usr/share/sound/test.wav")
radio = fallback(track_sensitive=false, [my_music, security])

video_stream = video.image("/home/radio/background.png")
rfe_broadcast = mux.video(video=video_stream, radio)

# Absolut nativer, abwärtskompatibler RTMP-Ausgang ohne Syntax-Fallen
output.url(
  url="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  %ffmpeg(format="flv", vcodec="libx264", acodec="aac"),
  rfe_broadcast
)
