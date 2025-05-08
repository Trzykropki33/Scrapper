require 'net/http'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'prawn'
require './data/car'
require './data/scrapper'
require './data/generator'
require 'selenium-webdriver'



# Inicjalizacja scrapera
# Poieranie Nazw marek
# Wybieranie Marki, ilosci stron raporu oraz pobieranie danych
# Zapis Raportu do PDF/CSV

scrapper = Scrapper.new
scrapper.scrape_brand
scrapper.get_data
scrapper.save_data
