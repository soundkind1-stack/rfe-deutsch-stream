import urllib.parse
import sys

def rebuild_playlist():
    try:
        m3u_url = 'https://archive.org'
        raw_file = '/home/radio/playlist_raw.txt'
        out_file = '/home/radio/playlist.txt'
        count = 0
        
        with open(raw_file, 'r', encoding='utf-8', errors='ignore') as src, open(out_file, 'w', encoding='utf-8') as dst:
            for line in src:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                url = urllib.parse.urljoin(m3u_url, line)
                dst.write(url + '\n')
                count += 1
        print(f"=== RFE: Generated {count} audio URLs ===")
    except Exception as e:
        print(f"=== RFE Builder Fehler: {str(e)} ===")
        sys.exit(12)

if __name__ == "__main__":
    rebuild_playlist()
