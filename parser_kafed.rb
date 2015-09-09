require_relative 'parser.rb'
require 'nokogiri'
require 'mechanize'

class Parser_kafed < Parser
  def main(name)
    agent=Mechanize.new
    dict={}
    teachers_list = []
    page = agent.get('http://rasp.sstu.ru/kafedra')
    page = agent.page.link_with(:text => name).click
    html = Nokogiri::HTML(page.body.force_encoding('UTF-8'))
    teachers_panels = html.css('div.panel-title-teacher')
    teachers_panels.each do |panel|
      teachers_list.push(panel.content.strip)
    end
    panels = html.css('div.panel-body')
    panels_list = []
    panels.each do |panel|
      a = panel.content.split("\r\n")
      b=[]
      a.each do |i|
        b.push(i.strip)
      end
      b = b.reject {|c| c.empty?}
      b.slice!(b.index('Чётная')+1..b.index('Чётная')+5)
      b.slice!(b.index('Нечётная')+1..b.index('Нечётная')+5)
      panels_list.push(b)
    end
    i = 0
    while i < teachers_list.length
      dict[teachers_list[i]] = panels_list[i]
      i += 1
    end

    dict.each do |k, v|
      pp v, '================================'
    end

  end
end

pars = Parser_kafed.new
pars.main('ИСТ')
#puts pars.main('1+411'.split('+').join('/'), group=false, teacher=false, auditory=true)