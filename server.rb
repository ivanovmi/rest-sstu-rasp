require 'sinatra'
require 'sinatra/json'
require_relative 'parser.rb'
require_relative 'parser_kafed'
require 'json'
require 'pp'

#========================================= SETTINGS SECTION ============================================================
# Start application on custom port
if /[\D]+/.match(ARGV[0])
  set :port, 1111
else
  if not ARGV[0].nil?
      set :port, ARGV[0].to_i
  else
      set :port, 1111
    end
  end

set :bind, '0.0.0.0'
# Set content-type for json
set :json_content_type, :js

# If this line uncommented - sinatra doesn't show error messages
disable :show_exceptions
disable :raise_errors
#============================================END SETTINGS===============================================================

get '/group=:group' do |group_name|
  json Parser.new.main(group_name, group=true, lector=false, auditory=false, kafedra=false)
end

get '/lector=:lector' do |lector_name|
  n = lector_name.split('+').join(' ')
  json Parser.new.main(n, group=false, lector=true, auditory=false, kafedra=false)
end

get '/aud=:aud' do |aud|
  json Parser.new.main(aud.to_s.split('+').join('/'), group=false, lector=false, auditory=true, kafedra=false)
end

get '/kafedra=:kafedra' do |kafedra_name|
  json Parser_kafed.new.main(kafedra_name)
end

get '/kafedra=:kafedra/lector=:lector' do |kafedra_name, lector_name|
  json Parser_kafed.new.main(kafedra_name, lector_name)
end

error 400..505 do
  body json hash = {}
end
