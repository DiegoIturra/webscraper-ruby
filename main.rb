require 'open-uri'
require 'nokogiri'
require 'csv'

class Scraper
    
    def initialize()
        @list_of_wishlist_urls = [
            'https://www.buscalibre.cl/v2/pendientes_486712_l.html'
        ]
    end

    def do_scraping_book(url)
        html = URI.open(url)
        document = Nokogiri::HTML(html)

        title = get_title(document)
        image_path = get_image_path(document)

        puts title
        puts image_path

    end

    def get_title(document)
        document.css('.tituloProducto').text
    end

    def get_image_path(document)
        document.css('.imagen img').find{|picture| picture.attributes["data-src"]}.attributes["data-src"].value
    end

    def get_price
        #get book price
    end

    def get_availability
        #return availability
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
                    link.attributes['href'].value
                    break
                }
            end
        end
    end

    def do_scraping
        get_all_books_urls
    end

end

scraper = Scraper::new
scraper.do_scraping_book('https://www.buscalibre.cl/libro-transmetropolitan-libro-02-de-5/9788417908928/p/52088837')