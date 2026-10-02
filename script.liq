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
# AUDIO ABSICHERN
# ------------------------------------------------------------
safe_music = mksafe(my_music)
safe_news  = mksafe(my_news)

# ------------------------------------------------------------
# DER STÜNDLICHE NEWS-TIMER-FIX (Präzise für Version 2.0.2)
# ------------------------------------------------------------
# Umschaltung NUR NOCH einmal pro Stunde exakt um XX:00:00 Uhr.
# track_sensitive=false zwingt das System, die Musik SOFORT zu pausieren.
# Die News-Quelle wird strikt von Anfang bis Ende abgespielt.
final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m0s-0m5s },  safe_news),
    ({ true },       safe_music)
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
