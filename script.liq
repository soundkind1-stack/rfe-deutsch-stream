my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")

# Zeitgesteuerte Umschaltung für Version 2.0.2
final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m-5m },  (my_news : source)),
    ({ 30m-35m }, (my_news : source)),
    ({ true },    (my_music : source))
  ]
)

# Das Audio wird direkt als lokaler Stream an den lauschenden FFmpeg-Prozess übergeben
output.url(
  url="rtmp://127.0.0.1:8000/live",
  %ffmpeg(format="flv", acodec="aac"),
  final_audio
)
