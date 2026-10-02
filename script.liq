# ============================================================================
# RADIO FREIES EURASIEN (RFE-DEUTSCH)
# Liquidsoap 2.0.2
# ============================================================================

set("init.allow_root", true)
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])
set("root.sync.buffer", 2.0)

# ------------------------------------------------------------
# ARCHIVE.ORG PLAYLIST
# ------------------------------------------------------------
my_music = playlist(mode="random", "/home/radio/playlist.txt")

# AUDIO ABSICHERN
final_audio = mksafe(my_music)

# ------------------------------------------------------------
# RAW PCM -> NAMED PIPE
# ------------------------------------------------------------
output.file(
  %wav(stereo=true, channels=2, samplesize=16, header=false),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
