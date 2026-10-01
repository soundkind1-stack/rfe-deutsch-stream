# 1. Die Musik- und News-Quellen definieren (spielt alle MP3s aus den Ordnern)
my_music = playlist("/home/radio/music")
my_news  = playlist("/home/radio/news")

# 2. Sicherheits-Mucke, falls mal ein Ordner leer ist (reines Rauschen/Stille verhindern)
security = single("/usr/share/sound/test.wav")

# 3. Das Hauptprogramm läuft in Dauerschleife
radio = fallback(track_sensitive=false, [my_music, security])

# 4. Der automatische News-Schnitt (Jeden Tag um XX:00 und XX:30 Uhr für max. 5 Minuten)
radio = switch([
  ({ 0m-5m }, my_news),
  ({ 30m-35m }, my_news),
  ({ true }, radio)
])

# 5. Den Stream an deine Ausgabestelle leiten (Konfiguration folgt)
output.dummy(radio)
