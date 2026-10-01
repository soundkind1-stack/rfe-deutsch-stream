# ==============================================================================
# RFE-DEUTSCH: AUDIO- & VIDEO-STREAMING CONFIGURATION WITH TWITCH KEY
# ==============================================================================

# 1. Die Audio-Quellen definieren (spielt alle MP3s aus den Ordnern)
my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")
security = single("/usr/share/sound/test.wav")

# Hauptprogramm-Audio in Dauerschleife
audio_stream = fallback(track_sensitive=false, [my_music, security])

# Der automatische News-Audio-Wechsel (Punkt und Halb nach Berliner Zeit)
final_audio = switch([
  ({ 0m-5m }, my_news),
  ({ 30m-35m }, my_news),
  ({ true }, audio_stream)
])

# 2. Das statische Hintergrundbild als Video-Spur laden
video_stream = video.image("/home/radio/background.png")

# 3. Audio und Video-Standbild zu einem echten Medien-Stream verschmelzen
rfe_broadcast = mux.video(video=video_stream, final_audio)

# 4. Der Live-Ausgang zu Twitch (Mit deinem echten Stream-Key eingebunden)
output.gstreamer(
  video_pipeline="videoconvert ! x264enc bitrate=1500 speed-preset=ultrafast tune=zerolatency ! video/x-h264,profile=baseline ! flvmux name=mux !",
  audio_pipeline="audioconvert ! voaacenc bitrate=128000 ! mux.",
  location="rtmp://live.twitch.tv/app/live_1508232326_549kYQXQJHoFg89JbHbUTXfSVYRA4u",
  rfe_broadcast
)
