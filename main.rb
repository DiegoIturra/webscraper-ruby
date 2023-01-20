require 'open-uri'
require 'nokogiri'
require 'csv'

class Scraper
    
    @@base_url = "https://en.wikipedia.org/wiki/Douglas_Adams"

    def initialize()
        html = URI.open(@@base_url) #get html file
        doc = Nokogiri::HTML(html) #parse html file
        description = doc.css("p").text.strip.split("\n")[0] #get first <p> text
        url_image = doc.css("img").find{|picture| picture.attributes["alt"].value.include?("Douglas adams portrait cropped.jpg")}.attributes["src"].value
        puts url_image

        #Export data to CSV
        data_arr = []
        data_arr.push(description, url_image)

        CSV.open('data.csv', "w") do |csv|
            csv << data_arr
        end
    end
end

scraper = Scraper::new