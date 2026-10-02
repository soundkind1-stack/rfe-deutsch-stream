# ============================================================================
# RADIO FREIES EURASIEN (RFE-DEUTSCH)
# Liquidsoap 2.0.2 - 24/7 REINE MUSIK-ENGINE
# ============================================================================

# SONDEREINSTELLUNG FÜR CLOUD-SERVER: Root-Ausführung erlauben
set("init.allow_root", true)

# GLOBALER FIX FÜR AUDIODATEIEN: FFmpeg als primären System-Decoder erzwingen!
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])

# ------------------------------------------------------------
# PLAYLIST (Endlosschleife & Live-Ordner-Scan aktiv!)
# ------------------------------------------------------------
my_music = playlist(mode="random", reload_mode="watch", "/home/radio/music")

# AUDIO ABSICHERN GEGEN DEFEKTE DATEIEN
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
