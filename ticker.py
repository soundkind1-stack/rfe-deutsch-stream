# Radio Freies Eurasien - Statischer Finanz-Ticker
# Absolut krisensicher ohne blockierende APIs

def fetch_ticker():
    try:
        # Hier sind deine gewünschten Kurse sauber aufgereiht
        btc_price = "76,950"
        gold_price = "4,176"
        eur_usd = "1.12"
        usd_rub = "93.94"
        
        # Einzeiliges Band mit der korrekten BTC-Bezeichnung
        ticker_content = f"BTC: ${btc_price}  |  GOLD (OZ): ${gold_price}  |  EUR/USD: {eur_usd}  |  USD/RUB: {usd_rub}"
        
        with open('/tmp/ticker.txt', 'w') as f:
            f.write(ticker_content)
        print("=== RFE Ticker: Textzeile erfolgreich generiert ===")
    except Exception as e:
        with open('/tmp/ticker.txt', 'w') as f:
            f.write("BTC: $76,950  |  GOLD: $4,176  |  EUR/USD: 1.12  |  USD/RUB: 93.94")

if __name__ == "__main__":
    fetch_ticker()
