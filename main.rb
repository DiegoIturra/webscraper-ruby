require 'open-uri'
require 'nokogiri'
require 'csv'

class Scraper
    
    def initialize()
        @list_of_wishlist_urls = [
            'https://www.buscalibre.cl/v2/pendientes_486712_l.html',
            'https://www.buscalibre.cl/v2/software-development_503034_l.html',
            'https://www.buscalibre.cl/v2/comics_545021_l.html'
        ]
    end

    def get_all_books_urls
        @list_of_wishlist_urls.each do |url|
            html = URI.open(url)
            document = Nokogiri::HTML(html)

            #Get main container for books
            box_product = document.css('.productos')
            
            #Iterate over each div container getting the link to book page
            box_product.css('.box-producto').each do |box|
                box.css('a').find{ |link| 
                    puts link.attributes['href'].value
                    break
                }
            end
        end
    end

    def do_scraping
        get_all_books_urls()
    end



end

scraper = Scraper::new
scraper.do_scraping