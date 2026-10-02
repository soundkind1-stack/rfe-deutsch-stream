# ============================================================================
# RADIO FREIES EURASIEN (RFE-DEUTSCH)
# Liquidsoap 2.0.2 - 24/7 ARCHIVE.ORG CLOUD-STREAM ENGINE
# ============================================================================

# SONDEREINSTELLUNG FÜR CLOUD-SERVER: Root-Ausführung erlauben
set("init.allow_root", true)

# GLOBALER FIX FÜR AUDIODATEIEN: FFmpeg als primären System-Decoder erzwingen!
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])

# ------------------------------------------------------------
# PLAYLIST (Streamt direkt und unbegrenzt aus dem Internet Archive!)
# ------------------------------------------------------------
my_music = playlist(mode="random", "https://archive.org/download/b-00-quem-9-tu-disc-1-11-niveau-weshalb-warum/b-00-quem-9-tu-disc-1-11-niveau-weshalb-warum_vbr.m3u")

# AUDIO ABSICHERN GEGEN NETZWERK-WACKLER
final_audio = mksafe(my_music)

# ------------------------------------------------------------
# RAW PCM AUSGABE AN DIE NAMED PIPE
# ------------------------------------------------------------
output.file(
  %wav(stereo=true, channels=2, samplesize=16, header=false),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
