my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")
security = single("/usr/share/sound/test.wav")

audio_stream = fallback(track_sensitive=false, [my_music, security])

final_audio = switch([
  ({ 0m-5m }, my_news),
  ({ 30m-35m }, my_news),
  ({ true }, audio_stream)
])

video_stream = video.image("/home/radio/background.png")
rfe_broadcast = mux.video(video=video_stream, final_audio)

output.gstreamer(
  video_pipeline="videoconvert ! x264enc bitrate=1500 speed-preset=ultrafast tune=zerolatency ! video/x-h264,profile=baseline ! flvmux name=mux !",
  audio_pipeline="audioconvert ! voaacenc bitrate=128000 ! mux.",
  location="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  rfe_broadcast
)
