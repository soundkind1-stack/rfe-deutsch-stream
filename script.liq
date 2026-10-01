# ============================================================
# RADIO FREIES EURASIEN
# Liquidsoap 2.0.2
# Audio -> raw PCM -> Named Pipe -> FFmpeg
# ============================================================

# ------------------------------------------------------------
# PLAYLISTEN
# ------------------------------------------------------------

my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")


# ------------------------------------------------------------
# MUSIK SICHER MACHEN
#
# Falls music/ leer ist oder keine Datei abgespielt werden kann,
# liefert mksafe() Stille statt Liquidsoap zu beenden.
# ------------------------------------------------------------

safe_music = mksafe(my_music)


# ------------------------------------------------------------
# NEWS + MUSIK-FALLBACK
#
# Während eines News-Zeitfensters:
#
#   News vorhanden  -> News
#   keine News      -> Musik
#   beides nicht    -> Stille
#
# mksafe() macht das Ergebnis anschließend garantiert
# infallible für den Haupt-Switch.
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
# HAUPTSTREAM
#
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
# RAW PCM AUSGABE
#
# Kein WAV-Header!
# FFmpeg liest:
#   s16le
#   44100 Hz
#   2 Kanäle
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
