require 'jaeger/client'
require 'jaeger/client/http_sender'
require 'mongo'
require 'mongodb/instrumentation'

def list_all(collection)
  collection.find.each do |document|
    puts document
  end
end

# set up the exporter
ingest_url = "http://localhost:14268/api/traces"
service_name = "mongodb-test"
headers = { }
encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)
http_sender = Jaeger::Client::HttpSender.new(url: ingest_url, headers: headers, encoder: encoder)
OpenTracing.global_tracer = Jaeger::Client.build(service_name: service_name, sender: http_sender)

# set up the instrumentation
MongoDB::Instrumentation.instrument

# suppress the logs, since the default makes reading the output difficult
Mongo::Logger.logger.level = ::Logger::FATAL

# create a connection to the local mongo instance
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'testdb')

# print collections directly
client.collections.each { |coll| puts coll.name }

# print collections by accessing a database
db = client.database
puts db.collection_names

# insert document
collection = client[:test_collection]
doc = { name: 'Test', value: 'TestValue'}
result = collection.insert_one(doc)
puts "Inserted #{result.n} document"

# insert many documents
docs = []
for i in 1..10 do
  docs << { name: "Test#{i}", value: "Value#{i}"}
end
result = collection.insert_many(docs)
puts "Inserted #{result.inserted_count} documents"

# query all documents
list_all(collection)

# update
result = collection.update_many( {}, { '$set' => { 'value' => 'test_updated' } } )
puts "Modified #{result.modified_count} documents"

# query
list_all(collection)

# delete document
result = collection.delete_one( { name: 'Test' } )
puts "Deleted #{result.deleted_count}"
list_all(collection)
result = collection.delete_many( { name: /Test/ } )
puts "Deleted #{result.deleted_count}"

list_all(collection)

documents = collection.find(:name => 'Test').skip(10).limit(10)

# delete the collection and close the connection
collection.drop
client.close

# sleep to let the Jaeger spans finish sending
sleep(10)
