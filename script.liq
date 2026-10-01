my_music = playlist("/home/radio/music")
security = single("/usr/share/sound/test.wav")
radio = fallback(track_sensitive=false, [my_music, security])

# Liquidsoap gibt das Audio jetzt einfach lokal als unkomprimierten Stream aus
output.icecast(%mp3(bitrate=128), host="localhost", port=8000, mount="radio.mp3", password="x", radio)
