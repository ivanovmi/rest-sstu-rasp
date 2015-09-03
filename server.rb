require 'sinatra'
require_relative 'parser.rb'
require 'json'


get '/hi' do
  "Hello World!"
end

get '/group=:group' do |n|
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  # n stores params['name']
  #JSON.pretty_generate(hash)
  main(n)
end

