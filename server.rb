require 'sinatra'
require_relative 'parser.rb'
require 'json'
require 'pp'

get '/hi' do
  "Hello World!"
end

get '/group=:group' do |n|
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  # n stores params['name']
  #JSON.pretty_generate(hash)
  Parser.new.main(n, group=true, teacher=false, kafedra=false)
end

get '/teacher=:teacher' do |m|
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  # n stores params['name']
  #JSON.pretty_generate(hash) puts n
  n = m.split('+').join(' ')
  pp n
  pp n.is_a?String
  pp n.nil?
  pars = Parser.new
  pars.main("Чугунов АВ", group=false, teacher=true, kafedra=false)
end

get '/kafedra=:kafedra' do |n|
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  # n stores params['name']
  #JSON.pretty_generate(hash)
  Parser.new.main(n, group=false, teacher=false, kafedra=true)
end

get '/example.json' do
  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
end
