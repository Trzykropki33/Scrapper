
# OTOMOTO Scraper

A Ruby-based command-line tool that scrapes car listings from [otomoto.pl](https://www.otomoto.pl) and exports the data to PDF or CSV files. Uses Nokogiri, Net::HTTP, and Selenium for data extraction and Prawn for PDF generation.

## 🧰 Features

- ✅ Scrapes car listings by brand
- ✅ Extracts details like price, mileage, fuel type, equipment, image, etc.
- ✅ Exports data to:
  - PDF file (with car cards and images)
  - CSV file (for structured data use)
- ✅ Interactive CLI for selecting brand and number of pages
- ✅ Bypasses OTOMOTO’s dynamic brand loading with Selenium

---

## 📦 Dependencies

You need to have **Ruby** installed, along with the following gems:

```bash
gem install nokogiri selenium-webdriver prawn
```

You also need **Google Chrome** and the matching version of [ChromeDriver](https://chromedriver.chromium.org/downloads) available in your PATH.

---

## ▶️ Usage

1. Clone the repository:

```bash
git clone https://github.com/yourusername/otomoto-scraper.git
cd otomoto-scraper
```

2. Run the script:

```bash
ruby main.rb
```

3. Follow the interactive prompts:

- Select a car brand
- Enter number of pages to scrape (each page has ~32 listings)
- Choose how to export the data (CSV, PDF, or both)

---

## 📂 Output

- CSV: `Report_YYYYMMDD_HHMMSS.csv`
- PDF: `Report_YYYYMMDD_HHMMSS.pdf`

Files will be saved in the current working directory.

---

## 📝 Example Output (PDF)

Each listing in the PDF includes:

- Car image
- Title and price
- Production year, fuel type, gearbox
- Mileage, power, tank, equipment
- Location

> PDF is laid out using a grid system with 3 listings per page.

---

## 📁 Project Structure

```
.
├── data/
├───── generator.rb     # Handles file export (PDF & CSV)
├───── scrapper.rb      # Main scraping logic
├───── car.rb           # Car data model (not shown here)
├── app.rb          # Entry point / CLI
└── fonts/           # Custom font files for PDF (e.g., Lato)
```

---

## ⚠️ Disclaimer

This tool is for educational purposes only. Make sure your use complies with OTOMOTO’s terms of service and robots.txt.

---

## 👤 Autor

Trzykropki33
GitHub: `@Trzykropki33`

---

## 📜 License

MIT License

---

## 🙋 Support or Contributions

Feel free to open issues or pull requests if you’d like to improve the tool. Contributions are welcome!
