require_relative 'parser.rb'
require 'nokogiri'
require 'mechanize'

class Parser_kafed < Parser

  def get_pairs(array)
    iter = 0
    dict = Hash.new
    while iter < array.length
      dict[array[iter]] = {:room => array[iter+1], :group => array[iter+2], :subject => array[iter+3]}
      iter += 4
    end
    dict
  end

  def parser(a)
    dict = {}
    odd_week = nil
    non_odd_week = nil
    week = {:Пн => 'monday', :Вт => 'tuesday', :Ср => 'wednesday', :Чт => 'thursday', :Пт => 'friday', :Сб => 'saturday'}
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

    dict.each do |k,v|
      storage = []
      tmp_storage = []
      reservoir = {}

      v.each do |element|
        if element.include? '.' and not element.include? ' '
          storage.push(v.index(element))
        end
      end
      storage.each_index do |i|
        if storage[i+1].nil?
          tmp_storage.push(v[storage[i]..a.length-1])
        else
          tmp_storage.push(v[storage[i]..storage[i+1]-1])
        end
      end

      tmp_storage.each do |element|
        reservoir[week[element[0][0..1].to_sym]] = get_pairs(element[1..element.length])
      end

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
      dict[teacher_name.split('+').join(' ')]
    else
      dict
    end
  end
end
