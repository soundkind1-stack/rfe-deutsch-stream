my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")
security = single("/usr/share/sound/test.wav")

audio_stream = fallback(track_sensitive=false, [my_music, security])

# Der automatische News-Wechsel (Punkt und Halb nach Berliner Zeit)
final_audio = switch([
  ({ 0h0m-0h5m }, my_news),
  ({ 0h30m-0h35m }, my_news),
  ({ true }, audio_stream)
])

# Audio lokal als unkomprimierte Wavedatei an die Systemausgabe leiten
output.file(%wav, "/home/radio/live.wav", final_audio)
