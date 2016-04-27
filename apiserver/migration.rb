require 'byebug'
require 'mongo'

mongo = Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])

puts mongo['devices'].indexes.create_one({ "hwid": 1 }, { unique: true })
