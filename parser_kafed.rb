require_relative 'parser.rb'

class Parser_kafed < Parser
  
end

pars = Parser_kafed.new
puts pars.main('2+019А'.split('+').join('/'), group=false, teacher=false, auditory=true)