require 'sinatra'
require_relative 'parser.rb'
require_relative 'parser_kafed'
require 'json'
require 'pp'

#========================================= SETTINGS SECTION ============================================================
set :port, 1111

# If this line uncommented - sinatra doesn't show error messages
disable :show_exceptions
disable :raise_errors
#============================================END SETTINGS===============================================================

get '/hi=:name' do |name|
  "Hello #{name}!"
end

get '/group=:group' do |group_name|
  Parser.new.main(group_name, group=true, lector=false, auditory=false, kafedra=false)
end

get '/lector=:lector' do |lector_name|
  n = lector_name.split('+').join(' ')
  Parser.new.main(n, group=false, lector=true, auditory=false, kafedra=false)
end

get '/aud=:aud' do |aud|
  Parser.new.main(aud.to_s.split('+').join('/'), group=false, lector=false, auditory=true, kafedra=false)
end

get '/kafedra=:kafedra' do |kafedra_name|
  Parser_kafed.new.main(kafedra_name)
end

get '/kafedra=:kafedra/lector=:lector' do |kafedra_name, lector_name|
  Parser_kafed.new.main(kafedra_name, lector_name)
end

error 400..505 do
  hash = {}
  body hash.to_json
end
