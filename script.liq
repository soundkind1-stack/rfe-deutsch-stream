# ============================================================================
# RADIO FREIES EURASIEN
# Liquidsoap 2.0.2
# Audio -> raw PCM -> Named Pipe -> FFmpeg
# ============================================================================

set("init.allow_root", true)
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])

# ------------------------------------------------------------
# PLAYLISTEN
# ------------------------------------------------------------
my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")

# ------------------------------------------------------------
# AUDIO ABSICHERN
# ------------------------------------------------------------
safe_music = mksafe(my_music)
news_or_music = mksafe(fallback(track_sensitive=false, [my_news, my_music]))

# ------------------------------------------------------------
# HAUPTSTREAM (Um Punkt News, sonst Musik)
# ------------------------------------------------------------
final_audio = switch(
  track_sensitive=false,
  [
    ({ 0m0s-0m5s },   news_or_music),
    ({ true },    safe_music)
  ]
)

# ------------------------------------------------------------
# RAW PCM AUSGABE
# ------------------------------------------------------------
output.file(
  %wav(stereo=true, channels=2, samplesize=16, header=false),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
