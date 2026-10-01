# Radio Freies Eurasien
# Liquidsoap 2.0.2
# Audio-Ausgabe als raw PCM über eine Linux Named Pipe

my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")

# Zeitgesteuerter Hauptstream:
# 00:00 - 04:59 -> News
# 30:00 - 34:59 -> News
# ansonsten       -> Musik
final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m-5m },  (my_news : source)),
    ({ 30m-35m }, (my_news : source)),
    ({ true },    (my_music : source))
  ]
)

# WAV-Encoder ohne WAV-Header = reines 16-bit PCM.
output.file(
  %wav(
    stereo=true,
    channels=2,
    samplesize=16,
    header=false
  ),
  "/home/radio/live.pipe",
  final_audio
)
