require 'sinatra'
require_relative 'parser.rb'
require_relative 'parser_kafed'
require 'json'
require 'pp'

#========================================= SETTINGS SECTION ============================================================
set :port, 1111

# If this line uncommented - sinatra doesn't show error messages
#set :show_exceptions, false
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
  pp kafedra_name, lector_name
  Parser_kafed.new.main(kafedra_name, lector_name)
end

get '/hello-world.json' do
  content_type :json # Content-Type: application/json;charset=utf-8

  # Use to_json to generate JSON based on the Ruby hash
  {   БлизниковаМП: {
        odd: {
          q: {
            room: "1/432",
            group: "м1-ИВЧТ21",
            subject: "Теория телетрафика и систем массового обслуживания"},
          w: {
            room: "1/426",
            group: "м1-ИВЧТ21",
            subject: "Теория телетрафика и систем массового обслуживания"}},
      non_odd: {
      e: {
     room: "1/432",
     group: "м1-ИВЧТ21",
     subject: "Теория телетрафика и систем массового обслуживания"
  }
  }
  },
      ВагаринаНС: {
      odd: {
      q: {
      room: "1/420",
      group: "б1-ИВЧТ11",
      subject: "Программирование"
  },
      w: {
      room: "1/427",
      group: "б1-ИВЧТ11",
      subject: "Программирование"
  }
  },
      non_odd: {
      w: {
      room: "1/420",
      group: "б1-ИВЧТ11",
      subject: "Программирование"
  },
      w: {
      room: "1/427",
      group: "б1-ИВЧТ31",
      subject: "Основы технологий семантического веба"
  },
      w: {
      room: "1/420",
      group: "б1-ИВЧТ11",
      subject: "Программирование"
  },
      w: {
      room: "1/427",
      group: "б1-ИВЧТ11",
      subject: "Программирование"
  }
  }
  },
  }.to_json
end

get '/example.json' do
  content_type :json
  #response = { "first"=> { "odd"=> false, "monday"=> { }, "wednesday"=> { "4"=> { "lector"=> "б1-ИВЧТ11", "subject"=> "Программирование(лаб)", "room"=> "1/420" } }, "thursday"=> { "2"=> { "lector"=> "б1-ИВЧТ31", "subject"=> "Основы технологий семантического веба(лек)", "room"=> "1/427" }, "3"=> { "lector"=> "б1-ИВЧТ11", "subject"=> "Программирование(прак)", "room"=> "1/420" } }, "friday"=> { "1"=> { "lector"=> "б1-ИВЧТ11", "subject"=> "Программирование(лек)", "room"=> "1/427" } } }, "second"=> { "odd"=> true, "monday"=> { }, "tuesday"=> { }, "wednesday"=> { }, "thursday"=> { "1"=> { "lector"=> "б1-ИВЧТ11", "subject"=> "Программирование(лаб)", "room"=> "1/420" }, "2"=> { "lector"=> "б1-ИВЧТ11", "subject"=> "Программирование(лек)", "room"=> "1/427" } }, "friday"=> { }, "saturday"=> { } } }
  hash = JSON["#{Parser_kafed.new.main('ИСТ').to_json}"]
  pp JSON.pretty_generate(hash)
  JSON.pretty_generate(hash)
end
