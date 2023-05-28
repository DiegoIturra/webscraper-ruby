#TODO: guardar datos en una base de datos no relacional
#TODO: guardar un timestamp por cada ejecucion del scraper
#TODO: generar un endopint para agregar un nueva url de lista de deseados para scraping
require 'mongo'
require 'pp'
require 'sinatra'
require 'json'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database

books_collection = client[:books]

data = []

books_collection.find.each do |document|
    data << document
end

get '/data' do
    content_type :json
    { data: data }.to_json
end


# books_collection.update_one({ title: "El Libro Rojo" }, { '$set' => { price: 1 } })

# books_collection.delete_many()

# #print collections in the current collection
# books_collection.find.each do |document|
#     pp document
#     puts ''
# end
