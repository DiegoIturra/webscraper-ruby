require 'open-uri'
require 'nokogiri'

class Scraper
    def initialize()
        html = URI.open("https://en.wikipedia.org/wiki/Douglas_Adams") #get html file
        doc = Nokogiri::HTML(html) #parse html file
        description = doc.css("p").text.strip.split("\n")[0] #get first <p> text
        puts description
    end
end

scraper = Scraper::new