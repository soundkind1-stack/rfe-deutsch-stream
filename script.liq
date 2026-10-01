# Radio Freies Eurasien
# Liquidsoap 2.0.2
# Audio-Ausgabe als raw PCM über Linux Named Pipe

# ------------------------------------------------------------
# PLAYLISTS
# ------------------------------------------------------------

my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")


# ------------------------------------------------------------
# SICHERE MUSIKQUELLE
#
# mksafe() macht aus der falliblen Playlist
# eine dauerhaft verfügbare Quelle.
# Wenn keine Musik verfügbar ist -> Stille.
# ------------------------------------------------------------

safe_music = mksafe(my_music)


# ------------------------------------------------------------
# NEWS-QUELLE MIT MUSIK ALS FALLBACK
#
# Während der News-Zeit:
#   News vorhanden -> News
#   keine News      -> Musik
#
# Dadurch bleibt auch ein leerer news/-Ordner ungefährlich.
# ------------------------------------------------------------

news_with_fallback = fallback(
  track_sensitive=false,
  [
    my_news,
    safe_music
  ]
)


# ------------------------------------------------------------
# HAUPTSTREAM
#
# 00:00 - 04:59 -> News
# 30:00 - 34:59 -> News
# sonst         -> Musik
#
# track_sensitive=false:
# Umschaltung erfolgt zum Zeitfenster und wartet
# nicht zwingend bis zum Ende eines Musikstücks.
# ------------------------------------------------------------

final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m-5m },   news_with_fallback),
    ({ 30m-35m }, news_with_fallback),
    ({ true },    safe_music)
  ]
)


# ------------------------------------------------------------
# AUSGABE
#
# WAV ohne Header = reines 16-bit PCM.
# FFmpeg liest dieses Signal aus der Named Pipe.
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
