require 'open-uri'
require 'nokogiri'
require 'concurrent-ruby'
require 'mongo'

class Scraper
    
    def initialize()
        @list_of_wishlist_urls = [
            'https://www.buscalibre.cl/v2/pendientes_486712_l.html',
            'https://www.buscalibre.cl/v2/software-development_503034_l.html',
            'https://www.buscalibre.cl/v2/comics_545021_l.html',
            'https://www.buscalibre.cl/v2/pendientes-2_567662_l.html',
            'https://www.buscalibre.cl/v2/historia_606807_l.html',
            'https://www.buscalibre.cl/v2/feminismo_624086_l.html',
            'https://www.buscalibre.cl/v2/pendientes-3_657656_l.html',
            'https://www.buscalibre.cl/v2/latinoamericana_711603_l.html',
            'https://www.buscalibre.cl/v2/estudio_727965_l.html',
            'https://www.buscalibre.cl/v2/literatura_729752_l.html',
            'https://www.buscalibre.cl/v2/contra_737670_l.html',
            'https://www.buscalibre.cl/v2/english-books_816771_l.html',
            'https://www.buscalibre.cl/v2/filosofia-sociologia_830510_l.html',
            'https://www.buscalibre.cl/v2/cortos_831079_l.html',
            'https://www.buscalibre.cl/v2/tolkien_921085_l.html',
            'https://www.buscalibre.cl/v2/fullmetal_1003773_l.html',
            'https://www.buscalibre.cl/v2/cuentos_1079781_l.html',
            'https://www.buscalibre.cl/v2/estudio2_1218140_l.html'
        ]

        @number_of_threads = 8
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
        begin
            document.css('.imagen img').find{|picture| picture.attributes["data-src"]}.attributes["data-src"].value
        rescue => e
            document.css('.imagen img').find{|picture| picture.attributes["src"]}.attributes["src"].value
        end
    end

    def get_price(document)
        #extract the first price belong to a new book instead of second hand book
        price = document.css('.precioAhora').text.split('$')[1]
        isEmpty?(price) ? nil : price.delete('.').to_i
    end

    def get_availability(document)
        get_price(document).nil? ? false : true
    end

    #Process a url of a list of wishlist
    def process_url(url, list_of_books_urls = [])
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

    def get_all_books_urls_concurrent
        split_urls = @list_of_wishlist_urls.each_slice((@list_of_wishlist_urls.size/@number_of_threads.to_f).ceil).to_a
        
        list_of_books_urls = []

        promises = split_urls.map.with_index do |urls, i|
            Concurrent::Promise.execute { urls.each { |url| process_url(url, list_of_books_urls) } }
        end

        # Wait for all threads to finish
        promises.each(&:wait)

        list_of_books_urls

    end

    #Deprecated
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
        get_all_books_urls_concurrent
    end

end


class ExecutionTask

    def initialize
        @scraper = Scraper::new
        @number_of_threads = 8

    end

    def get_all_data
        list_of_books_urls = get_list_of_all_books
        threads = []

        start_time = Time.now

        list_of_books_urls.each_slice((list_of_books_urls.size/@number_of_threads.to_f).ceil) do |urls|
            threads << Thread.new do
                urls.each do |url|
                    @scraper.do_scraping_book(url)
                end
            end
        end

        threads.each(&:join)

        end_time = Time.now

        puts "Time to get all info #{end_time - start_time} seconds"

    end

    private 
    def get_list_of_all_books
        @scraper.do_scraping
    end

end

class DatabaseConnection

    def self.connect()
        client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
        @database = client.database
    end

    def self.disconnect
        @database.client.close
    end

    def self.database
        @database
    end

end

task = ExecutionTask.new 
#task.get_all_data

#Perform database connection, getter and disconnect
DatabaseConnection.connect()
database = DatabaseConnection.database
DatabaseConnection.disconnect