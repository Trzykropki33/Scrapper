# frozen_string_literal: true
# This class is responsible for generating output files (PDF or CSV)
# from a collection of Car objects.
class Generator

  # Draws a visual representation of a Car object in a PDF document using grid layout.
  #
  # @param pdf [Prawn::Document] The open PDF document to draw on.
  # @param car [Car] An instance of the Car class to render.
  # @param row [Integer] Row position in the PDF grid layout.
  # @param col [Integer] Column position in the PDF grid layout.
  def draw_car_card(pdf, car, row, col)
      add_image_from_url(pdf,car.image.to_s,row,col)

      info = []
      info << car.tank
      info << car.power
      info << car.mileage
      info << car.fuel_type
      info << car.gearbox

      pdf.grid([row,col+2],[row+2,col+4]).bounding_box do
        pdf.text("#{car.title}", size:16)
      end
      pdf.grid([row+3,col+2],[row+3,col+2]).bounding_box do
        pdf.text("#{car.price} #{car.currency}", size:12)
      end
      pdf.grid([row+3,col+4],[row+3,col+4]).bounding_box do
        pdf.text("#{car.production_date}", size:10)
      end
      pdf.grid([row+4,col+2],[row+4,row+4]).bounding_box do
        pdf.text("#{info.join(" / ")}", size:10)
      end
      pdf.grid([row+5,col+2],[row+6,col+4]).bounding_box do
        pdf.text("#{car.equipment}", size:10)
      end
      pdf.grid([row+7,col+2],[row+7,col+4]).bounding_box do
        pdf.text("#{car.location}", size:8)
      end
  end


  # Generates a PDF file from an array of Car objects and saves it to disk.
  #
  # @param cars [Array<Car>] An array of Car instances to include in the PDF.
  def save_to_pdf_file(cars)
    file_name="Report_#{DateTime.now.strftime("%Y%m%d_%H%M%S").to_s}.pdf"
    Prawn::Document.generate(file_name) do |pdf|
      pdf.font_families.update(
        "Lato" => {
          normal: "./fonts/Lato/Lato-Regular.ttf",
          bold: "./fonts/Lato/Lato-Bold.ttf"
        }
      )
      pdf.font('Lato')
      pdf.define_grid(rows: 30, columns: 5, gutter: 10)
      cars.each_with_index do |car, i|
        position_in_grid = i % 3

        row = position_in_grid * 10

        pdf.start_new_page if i > 0 && position_in_grid == 0
        draw_car_card(pdf, car, row, 0)
      end
    end
  end

  # Downloads an image from a given URL and draws it in the PDF document.
  #
  # @param pdf [Prawn::Document] The open PDF file to draw into.
  # @param url [String] URL of the image to download and embed.
  # @param row [Integer] Row position in the grid layout.
  # @param col [Integer] Column position in the grid layout.
  def add_image_from_url(pdf, url,row,col)
    ext = '.jpg'
    tmp_path = "./tmp#{ext}"

    URI.open(url) do |image|
      File.open(tmp_path, 'wb') do |file|
        file.write(image.read)
      end
    end
    pdf.grid([row+1, col], [row+9, col+1]).bounding_box do
      pdf.image(tmp_path, width: 200, height: 200)
    end
    File.delete(tmp_path) if File.exist?(tmp_path)
  end

  # Saves a collection of Car objects to a CSV file.
  #
  # @param cars [Array<Car>] An array of Car instances to export to CSV.
  def save_to_csv_file(cars)
    file_name="Report_#{DateTime.now.strftime("%Y%m%d_%H%M%S").to_s}.csv"
    f = File.new("#{file_name}", "w")
    cars.each do |node|
      f.write("#{node.to_csv_file}\n")
    end
  end
end
