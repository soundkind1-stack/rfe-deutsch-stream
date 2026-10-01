my_music = playlist("/home/radio/music")
security = single("/usr/share/sound/test.wav")
radio = fallback(track_sensitive=false, [my_music, security])

video_stream = video.image("/home/radio/background.png")
rfe_broadcast = mux.video(video=video_stream, radio)

output.url(
  url="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  %ffmpeg(
    format="flv",
    vcodec="libx264",
    vsetting=[("preset","ultrafast"),("tune","zerolatency"),("b","1500k")],
    acodec="aac",
    asetting=[("b","128k")]
  ),
  rfe_broadcast
)
