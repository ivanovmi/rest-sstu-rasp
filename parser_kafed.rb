require_relative 'parser.rb'

class Parser_kafed < Parser

end

pars = Parser_kafed.new
puts pars.main('1+411'.split('+').join('/'), group=false, teacher=false, auditory=true)