set("init.allow_root", true)
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])

my_music = playlist(mode="random", reload_mode="watch", "/home/radio/music")
final_audio = mksafe(my_music)

output.file(
  %wav(stereo=true, channels=2, samplesize=16, header=false),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
