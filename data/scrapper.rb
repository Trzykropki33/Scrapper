# This class is responsible for scraping data from the OTOMOTO website
# and processing it into Car objects.
#
# @!attribute [rw] cars
#   @return [Array<Car>] The list of cars scraped from the site
#
# @!attribute [rw] brands
#   @return [Array<Hash>] The available car brands and their listing counts
#
# @!attribute [r] generator
#   @return [Generator] The generator instance used to save data to files
class Scrapper
  attr_accessor :cars, :brands
  attr_reader :generator

  def initialize
    @cars = []
    @generator = Generator.new
    @brands = nil
  end

  # Scrapes car listing data from OTOMOTO using the selected brand and number of pages.
  #
  # @return [void]
  def get_data
    brand,page = chose_brand(@brands)
    page.times do |page_num|
    uri = URI("https://www.otomoto.pl/osobowe/#{brand}?page=#{page_num+1}")
    req = Net::HTTP::Get.new(uri)
    req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/122.0.0.0 Safari/537.36'
    req['Accept'] = '*/*'

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    doc = Nokogiri::HTML(res.body)

    articles = doc.css("article[data-id]").select do |node|
      node['data-id'] =~ /\d+/
    end
      articles.each do |article|
        @cars << scrape(article)
      end
    end
  end

  # Uses Selenium to dynamically extract all car brands from the OTOMOTO homepage.
  #
  # @return [void]
  def scrape_brand
    options = Selenium::WebDriver::Chrome::Options.new
    prefs = {
      'profile.default_content_setting_values.notifications' => 2
    }
    options.add_preference(:prefs, prefs)
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-infobars')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('--disable-notifications')

    driver = Selenium::WebDriver.for :chrome, options: options
    wait = Selenium::WebDriver::Wait.new(timeout: 1)

    begin
      driver.navigate.to 'https://www.otomoto.pl/'

      wait.until { driver.find_element(id: 'onetrust-accept-btn-handler').displayed? }
      driver.find_element(id: 'onetrust-accept-btn-handler').click

      input = driver.find_element(xpath: '//*[@id="__next"]/div[1]/div/div/main/div[1]/article/article/fieldset/form/section[1]/div[1]/div[1]/div/input')
      input.click

      wait.until do
        driver.find_elements(xpath: '//div[@role="radio" and @type="selectable"]').any?
      end

      all_options = driver.find_elements(xpath: '//div[@role="radio" and @type="selectable"]')

      filtered_brands = all_options.select do |el|
        id = el.attribute("id")
        text = el.text.strip

        next false if id.nil? || id.empty?
        next false if id.start_with?("top-make-") || id.start_with?("-1")
        next false if text.match?(/Popularne|Alfabetycznie|Wybierz|Wszystko/i)

        true
      end

      @brands = filtered_brands.map do |el|
        name, count = el.text.strip.match(/(.+?)\s+\((\d+)\)/).captures
        { name: name.downcase, count: count.to_i }
      end.select { |brand| brand[:count] > 0 }

    ensure
      driver.quit
    end
  end

  # Parses and transforms a Nokogiri HTML article node into a Car object.
  #
  # @param articles [Nokogiri::XML::Element] The HTML node representing a car listing
  # @return [Car] A populated Car object
  def scrape(articles)
    car = Car.new
    car.image = articles.at('img')['src']
    car.title = articles.xpath(".//a[contains(@target, '_self')]/text()").text
    car.price = articles.xpath(".//section/div[4]/div[2]/div/h3").text
    car.currency = articles.xpath(".//section/div[4]/div[2]/div/p").text
    info = articles.xpath(".//section/div[2]/p").text.split("•")
    car.tank =info[0]
    car.power = info[1]
    car.equipment = info[2]
    car.mileage = articles.xpath(".//section/div[3]/dl[1]/dd[1]").text
    car.fuel_type = articles.xpath(".//section/div[3]/dl[1]/dd[2]").text
    car.gearbox = articles.xpath(".//section/div[3]/dl[1]/dd[3]").text
    car.production_date = articles.xpath(".//section/div[3]/dl[1]/dd[4]").text
    car.location = articles.xpath(".//section/div[3]/dl[2]/dd[1]/p").text
    car
  end

  # Displays information about all collected cars in the terminal.
  #
  # @return [void]
  def show_data
    @cars.each do |car|
      car.show_info
    end
  end

  # Displays the list of brands in a formatted layout in the terminal.
  #
  # @param brands [Array<Hash>] The list of brands to display
  # @return [void]
  def show_brands(brands)
    brand_names = brands.map { |b| b[:name] }

    brand_names.each_with_index do |name, index|
      print "#{name}\t"
      puts if (index + 1) % 6 == 0
    end
  end

  # Asks the user to choose how to save the data (CSV, PDF or both).
  #
  # @return [void]
  def save_data
    puts "Save as: \n 1. CSV\n 2. PDF \n 3. CSV&PDF \n 0. Exit\n"
    opt = -1
    while opt != 0
      opt = gets.chomp
      case opt.to_i
      when 1
        puts "Saving...."
        @generator.save_to_csv_file(@cars)
        puts "Done!"
        break
      when 2
        puts "Saving...."
        @generator.save_to_pdf_file(@cars)
        puts "Done!"
        break
      when 3
        puts "Saving...."
        @generator.save_to_csv_file(@cars)
        @generator.save_to_pdf_file(@cars)
        puts "Done!"
        break
      when 4
        opt = 0
      else
          puts "Wrong option!"
      end
    end
  end
end

# Prompts the user to choose a car brand from the list and number of pages to scrape.
#
# @param brands [Array<Hash>] The list of car brands with counts
# @return [Array(String, Integer)] The selected brand name and number of pages
def chose_brand(brands)
  show_brands(brands)
  puts "\n\nWrite brand:"

  loop do
    input = gets.strip.downcase
    match = brands.find { |b| b[:name].downcase == input }

    if match
      puts "Found: #{match[:name]} with #{match[:count]} listings"
      max_pages = (match[:count] / 32).to_i

      loop do
        puts "How many pages to read? (1 - #{max_pages})"
        i = gets.to_i

        if i.between?(1, max_pages)
          return match[:name], i  # ← zwraca string i integer
        else
          puts "Invalid number. Try again:"
        end
      end
    else
      puts "No results. Try again:"
    end
  end
end