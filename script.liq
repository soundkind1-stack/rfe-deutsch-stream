set("init.allow_root", true)
set("decoder.priorities", ["ffmpeg", "mad", "flac", "ogg"])
set("root.sync.buffer", 2.0)

my_music = playlist(mode="random", "/home/radio/playlist.txt")
final_audio = mksafe(my_music)

output.file(
  %wav(stereo=true, channels=2, samplesize=16, header=false),
  append=false,
  "/home/radio/live.pipe",
  final_audio
)
