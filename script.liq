# ============================================================================
# RADIO FREIES EURASIEN
# Liquidsoap 2.0.2
# Audio -> raw PCM -> Named Pipe -> FFmpeg
# ============================================================================

# SONDEREINSTELLUNG FÜR CLOUD-SERVER: Root-Ausführung erlauben
set("init.allow_root", true)

# ------------------------------------------------------------
# PLAYLISTEN
# ------------------------------------------------------------
my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")

# ------------------------------------------------------------
# MUSIK SICHER MACHEN
# Falls music/ leer ist, liefert mksafe() Stille statt Absturz.
# ------------------------------------------------------------
safe_music = mksafe(my_music)

# ------------------------------------------------------------
# NEWS + MUSIK-FALLBACK
# ------------------------------------------------------------
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
# 00:00 - 04:59 -> News / Musik-Fallback
# 30:00 - 34:59 -> News / Musik-Fallback
# ansonsten     -> Musik
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
# RAW PCM AUSGABE (Kein WAV-Header!)
# ------------------------------------------------------------
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
