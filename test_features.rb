#TODO: guardar datos en una base de datos no relacional
#TODO: guardar un timestamp por cada ejecucion del scraper
require 'mongo'
require 'pp'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database

books_collection = client[:books]

#print collections in the current collection
books_collection.find.each do |document|
    pp document
    puts ''
end
