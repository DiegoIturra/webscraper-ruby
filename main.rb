require 'open-uri'
require 'nokogiri'

class Scraper
    
    def initialize()
        @list_of_wishlist_urls = [
            'https://www.buscalibre.cl/v2/literatura_729752_l.html'
        ]
    end

    def do_scraping_book(url)
        html = URI.open(url)
        document = Nokogiri::HTML(html)

        title = get_title(document)
        image_path = get_image_path(document)
        price = get_price(document)
        availability = get_availability(document)

        puts title
        puts image_path
        puts price
        puts availability
        puts ""
    end

    def convert_price_to_integer price
        splited_price = price.split('.')

        number = splited_price.reduce{ |st1 , st2|  st1.strip + st2.strip }
        number.to_i
    end

    def isEmpty?(price)
        price.nil? ? true : price.empty?
    end

    def get_title(document)
        document.css('.tituloProducto').text
    end

    def get_image_path(document)
        document.css('.imagen img').find{|picture| picture.attributes["data-src"]}.attributes["data-src"].value
    end

    def get_price(document)
        #extract the first price belong to a new book instead of second hand book
        price = document.css('.precioAhora').text.split('$')[1]

        isEmpty?(price) ? "" : price 
    end

    def get_availability(document)
        get_price(document).empty? ? false : true
    end


    def get_all_books_urls
        list_of_books_urls = []

        @list_of_wishlist_urls.each do |url|
            html = URI.open(url)
            document = Nokogiri::HTML(html)

            #Get main container for books
            box_product = document.css('.productos')
            
            #Iterate over each div container getting the link to book page
            box_product.css('.box-producto').each do |box|
                box.css('a').find{ |link| 
                    book_url = link.attributes['href'].value
                    list_of_books_urls.push(book_url)
                    break
                }
            end
        end

        list_of_books_urls

    end

    def do_scraping
        get_all_books_urls
    end

end

scraper = Scraper::new
list_of_books_urls = scraper.do_scraping

number_of_threads = 4
threads = []

start_time = Time.now

list_of_books_urls.each_slice((list_of_books_urls.size/4.0).ceil) do |urls|
    threads << Thread.new do
        urls.each do |url|
            scraper.do_scraping_book(url)
        end
    end
end

threads.each(&:join)

end_time = Time.now

puts "Time to get all info #{end_time - start_time} seconds"
