import urllib.request
import re
import json

def fetch_ticker():
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        
        # 1. Bitcoin Kurs holen
        req_btc = urllib.request.Request('https://yahoo.com', headers=headers)
        with urllib.request.urlopen(req_btc) as resp:
            data_btc = json.loads(resp.read().decode('utf-8'))
            btc = int(data_btc['chart']['result'][0]['meta']['regularMarketPrice'])

        # 2. Gold Kurs holen
        req_gold = urllib.request.Request('https://yahoo.com', headers=headers)
        with urllib.request.urlopen(req_gold) as resp:
            data_gold = json.loads(resp.read().decode('utf-8'))
            gold = int(data_gold['chart']['result'][0]['meta']['regularMarketPrice'])

        # 3. Silber Kurs holen
        req_silber = urllib.request.Request('https://yahoo.com', headers=headers)
        with urllib.request.urlopen(req_silber) as resp:
            data_silber = json.loads(resp.read().decode('utf-8'))
            silber = round(data_silber['chart']['result'][0]['meta']['regularMarketPrice'], 2)

        # 4. DAX Kurs holen
        req_dax = urllib.request.Request('https://yahoo.com^GDAXI', headers=headers)
        with urllib.request.urlopen(req_dax) as resp:
            data_dax = json.loads(resp.read().decode('utf-8'))
            dax = int(data_dax['chart']['result'][0]['meta']['regularMarketPrice'])

        # Saubere, kurze Textseiten schreiben
        ticker_content = (
            f"MARKET OVERVIEW\n"
            f"BITCOIN (BTC): ${btc:,}\n"
            f"GOLD: ${gold:,} | SILBER: ${silber}\n"
            f"DAX INDEX: {dax:,}"
        )
        
        with open('/tmp/ticker.txt', 'w') as f:
            f.write(ticker_content)
        print("=== RFE Ticker: Marktdaten erfolgreich geladen ===")
    except Exception as e:
        with open('/tmp/ticker.txt', 'w') as f:
            f.write("MARKET DATA\nLOADING...\nLIVE DATA\nRADIO FREIES EURASIEN")
        print(f"=== RFE Ticker Fehler: {str(e)} ===")

if __name__ == "__main__":
    fetch_ticker()
