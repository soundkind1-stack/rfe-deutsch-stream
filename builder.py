import urllib.request
import xml.etree.ElementTree as ET
import sys

def rebuild_playlist():
    try:
        # Deine echte Archive.org ID nutzen!
        item_id = "b-00-quem-9-tu-disc-1-11-niveau-weshalb-warum"
        xml_url = f"https://archive.org{item_id}/{item_id}_files.xml"
        out_file = '/home/radio/playlist.txt'
        
        headers = {'User-Agent': 'Mozilla/5.0 RFE-Radio/1.0'}
        req = urllib.request.Request(xml_url, headers=headers)
        
        with urllib.request.urlopen(req) as response:
            xml_data = response.read()
            
        root = ET.fromstring(xml_data)
        count = 0
        
        with open(out_file, 'w', encoding='utf-8') as dst:
            for file_tag in root.findall('file'):
                name = file_tag.get('name')
                format_tag = file_tag.find('format')
                
                # Nur echte MP3-Dateien herausfiltern
                if name and format_tag is not None and "MP3" in format_tag.text:
                    file_url = f"https://archive.org{item_id}/{name}"
                    dst.write(file_url + '\n')
                    count += 1
                    
        print(f"=== RFE: Generated {count} audio URLs ===")
    except Exception as e:
        print(f"=== RFE Builder Fehler: {str(e)} ===")
        # Absolutes Fallback falls die XML noch im book_op hängt
        with open('/home/radio/playlist.txt', 'w') as dst:
            dst.write("https://archive.orgb-00-quem-9-tu-disc-1-11-niveau-weshalb-warum/B00QUELT4G_(disc_1)_01_-_So'ne_Musik.mp3\n")
        print("=== RFE Builder: Fallback-Playlist geschrieben ===")

if __name__ == "__main__":
    rebuild_playlist()
