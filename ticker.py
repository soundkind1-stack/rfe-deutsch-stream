import urllib.request
import re
import sys

def fetch_ticker():
    try:
        # 1. Finanzen.net RSS-Feed abgreifen
        req = urllib.request.Request('https://finanzen.net', headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            html = response.read().decode('utf-8')
        titles = re.findall(r'<title><\!\[CDATA\[(.*?)\]\]></title>', html)
        feed_text = ' +++ '.join([t for t in titles if 'finanzen.net' not in t])
        
        # 2. Bitcoin-Kurs live holen
        with urllib.request.urlopen('https://coindesk.com') as btc_resp:
            btc_data = btc_resp.read().decode('utf-8')
            btc_price = re.search(r'"rate":"(.*?)"', btc_data).group(1).split('.')[0]
            
        ticker = f'+++ RADIO FREIES EURASIEN WIRTSCHAFTSTICKER +++ BITCOIN: ${btc_price} +++ FINANZEN.NET MARKTREPORT: {feed_text} +++ '
        with open('/tmp/ticker.txt', 'w') as f:
            f.write(ticker * 2)
        print("=== RFE Ticker: Daten erfolgreich aktualisiert ===")
    except Exception as e:
        with open('/tmp/ticker.txt', 'w') as f:
            f.write('+++ RFE WIRTSCHAFTSTICKER: Lade Marktdaten... +++ ')
        print(f"=== RFE Ticker Warnung: {str(e)} ===")

if __name__ == "__main__":
    fetch_ticker()
