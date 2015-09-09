require_relative 'parser.rb'
require 'nokogiri'
require 'mechanize'

class Parser_kafed < Parser
  def parser(a)
    dict = {}
    odd = a.index('Нечётная')
    non_odd = a.index('Чётная')

    if odd > non_odd
      non_odd_week=a[1..odd-1]
      odd_week=a[odd+1..a.length-1]
    elsif non_odd > odd
      odd_week=a[1..non_odd-1]
      non_odd_week=a[non_odd+1..a.length-1]
    end

    dict['odd']=odd_week
    dict['non_odd']=non_odd_week
    week = {'Пн' => 'monday', 'Вт' => 'tuesday', 'Ср' => 'wednesday', 'Чт' => 'thursday', 'Пт' => 'friday', 'Сб' => 'saturday'}
    dict.each do |k,v|
      с = 0
      z = []
      m = {}
      l = {}
      while с < v.length
        if v[с].length==7 and v[с].include?'.'
          m[week[v[с][0..1]]] = z
        else
          z.push(v[с])
        end
        с += 1
      end
      m.each do |ke ,el|
        j=0
        while j < el.length
          l[el[j]] = {'room' => el[j+1], 'group' => el[j+2], 'subject' => el[j+3]}
          j+=4
        end
      end
      dict[k] = l
    end
  end

  def main(name, teacher_name=nil)
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
      dict[k] = parser(v)
    end

    if teacher_name
      hash = JSON["#{dict[teacher_name.split('+').join(' ')].to_json}"]
      JSON.pretty_generate(hash)
    else
      hash = JSON["#{dict.to_json}"]
      JSON.pretty_generate(hash)
    end
  end
end

#pars = Parser_kafed.new
#pars.main('РКД')
#puts pars.main('РКД', 'Акатова+ОИ')