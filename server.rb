require 'sinatra'
require_relative 'parser.rb'
require 'json'
require 'pp'

get '/hi=:name' do |name|
  "Hello #{name}!"
end

get '/group=:group' do |group_name|
  Parser.new.main(group_name, group=true, teacher=false, kafedra=false)
end

get '/teacher=:teacher' do |teacher_name|
  n = teacher_name.split('+').join(' ')
  pars = Parser.new
  pars.main(n, group=false, teacher=true, kafedra=false)
end

get '/aud=:aud' do |aud|
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
