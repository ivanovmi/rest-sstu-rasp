require_relative 'parser.rb'
require 'nokogiri'
require 'mechanize'

class Parser_kafed < Parser
  def parser(a)
    dict = {}
    odd_week = nil
    non_odd_week = nil
    odd = a.index('Нечётная')
    non_odd = a.index('Чётная')

    if not odd.nil? and not non_odd.nil?
      if odd > non_odd
        non_odd_week=a[1..odd-1]
        odd_week=a[odd+1..a.length-1]
      elsif non_odd > odd
        odd_week=a[1..non_odd-1]
        non_odd_week=a[non_odd+1..a.length-1]
      end
    else
      if odd.nil?
        non_odd_week=a[1..a.length-1]
        odd_week = []
      elsif non_odd.nil?
        odd_week=a[1..a.length-1]
        non_odd_week = []
      end
    end


    dict[:odd]=odd_week
    dict[:non_odd]=non_odd_week
    week = {:Пн => 'monday', :Вт => 'tuesday', :Ср => 'wednesday', :Чт => 'thursday', :Пт => 'friday', :Сб => 'saturday'}
    dict.each do |k,v|
      iter = 0
      storage = []
      reservoir = {}
      tmp_storage = {}
      v.each do |element|
        
        if element.include? '.' and not element.include? ' '
          name = element
          reservoir[element] = []
          start = true
          #break
        if start
          reservoir[name].push(element)
          #start = false
        end
        pp reservoir
        end
      end

      #pp v, '-----------'
=begin
      while iter < v.length
        if v[iter].length==7 and v[iter].include?'.'
          reservoir[week[v[iter][0..1].to_sym]] = storage
        else
          storage.push(v[iter])
        end
        iter += 1
      end
      reservoir.each do |key ,value|
        j=0
        while j < value.length
          tmp_storage[value[j]] = {:room => value[j+1], :group => value[j+2], :subject => value[j+3]}
          j+=4
          reservoir[key] = tmp_storage
        end
      end
=end
      dict[k] = reservoir
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

      if b.index('Чётная').nil?
        b.slice!(b.index('Нечётная')+1..b.index('Нечётная')+5)
      elsif b.index('Нечётная').nil?
        b.slice!(b.index('Чётная')+1..b.index('Чётная')+5)
      else
        b.slice!(b.index('Чётная')+1..b.index('Чётная')+5)
        b.slice!(b.index('Нечётная')+1..b.index('Нечётная')+5)
      end

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
    else
      hash = JSON["#{dict.to_json}"]
    end
 #   JSON.pretty_generate(hash)
  end
end

Parser_kafed.new.main('АЭУ', 'Алексеев+ВС')
#pp Parser_kafed.new.main('АЭУ', 'Алексеев+ВС')