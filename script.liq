# ============================================================================
# RADIO FREIES EURASIEN
# Liquidsoap 2.0.2
# Audio -> raw PCM -> Named Pipe -> FFmpeg
# ============================================================================

# SONDEREINSTELLUNG FÜR CLOUD-SERVER: Root-Ausführung erlauben
set("init.allow_root", true)

# ------------------------------------------------------------
# PLAYLISTEN (Unendliche Schleife & Live-Ordner-Scan aktiv!)
# ------------------------------------------------------------
# mode="random" mischt deine Songs durch.
# reload_mode="watch" sorgt dafür, dass neu hochgeladene MP3s sofort erkannt werden.
my_music = playlist(mode="random", reload_mode="watch", "/home/radio/music")
my_news  = playlist(mode="random", reload_mode="watch", "/home/radio/news")

# ------------------------------------------------------------
# AUDIO ABSICHERN GEGEN DEFEKTE / LEERE ORDNER
# ------------------------------------------------------------
safe_music = mksafe(my_music)

news_or_music = mksafe(
  fallback(
    track_sensitive=false,
    [
      my_news,
      my_music
    ]
  )
)

# ------------------------------------------------------------
# HAUPTSTREAM (Zeitgesteuert für Version 2.0.2)
# ------------------------------------------------------------
final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m-5m },   news_or_music),
    ({ 30m-35m }, news_or_music),
    ({ true },    safe_music)
  ]
)

# ------------------------------------------------------------
# RAW PCM AUSGABE
# ------------------------------------------------------------
output.file(
  %wav(
    stereo=true,
    channels=2,
    samplesize=16,
    header=false
  ),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
