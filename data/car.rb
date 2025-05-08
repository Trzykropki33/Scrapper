# This class represents a car data transfer object (DTO) used to encapsulate
# car-related information such as price, mileage, fuel type, and more.
# It provides utility methods for displaying data and exporting to CSV.
class Car
  attr_accessor :image, :title, :price, :currency, :tank, :power,
                :equipment, :mileage, :fuel_type, :gearbox,
                :production_date, :location

  def initialize(image: nil, title: nil, price: nil, currency: nil, tank: nil, power:nil, equipment: nil,
                 mileage:nil, fuel_type:nil, gearbox:nil, production_date:nil, location:nil )
    @image = image
    @title = title
    @price = price
    @currency = currency
    @tank = tank
    @power = power
    @equipment = equipment
    @mileage = mileage
    @fuel_type = fuel_type
    @gearbox = gearbox
    @production_date = production_date
    @location = location
  end

  # Displays all properties of the car object in a readable format
  # via terminal output. Useful for debugging or quick overviews.
  def show_info
    puts "Image path\t: #{image}"
    puts "Title \t\t: #{title}"
    puts "Price \t\t: #{price}"
    puts "Currency \t: #{currency}"
    puts "Tank \t\t: #{tank}"
    puts "Power \t\t: #{power}"
    puts "Equipment \t: #{equipment}"
    puts "Mileage \t: #{mileage}"
    puts "Fuel type \t: #{fuel_type}"
    puts "Gearbox \t: #{gearbox}"
    puts "Production date : #{production_date}"
    puts "Location \t: #{location}"
  end

  # Converts the car object's attributes into a single CSV-formatted string.
  # Returns:
  # - A string where attributes are comma-separated and in declaration order.
  def to_csv_file
    values = instance_variables.map do |var|
      instance_variable_get(var)
    end
    values.join(",")
  end
end

