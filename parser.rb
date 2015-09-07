require 'json'
require 'mechanize'
require 'net/https'
require 'nokogiri'
require 'unicode'
require 'json'

class String
  def is_upper?
    self == Unicode::upcase(self)
  end

  def is_lower?
    self == Unicode::downcase(self)
  end
end

class Parser
  def get_pairs(string)
    dict = {}

    if string.nil? or string.length == 1
      dict
    else
      dict['lector'] = string.split(')')[1]
      subj_room = string.split(')')[0]<<')'
      room = subj_room[0..4]
      subj_room[0..4] = ''
      subj = subj_room
      false_check = 0
      subj.split('')[0..3].each do |i|
        if i.is_lower?
          false_check += 1
        end
      end
      if false_check == 2
        room << subj[0]
        subj[0] = ''
      elsif false_check == 3 and subj[0].is_lower?
        room << subj[0]
        subj[0] = ''
      end
      dict['subject'] = subj
      dict['room'] = room
      dict
    end
  end

  def rasp_pars(page)
    response = Hash.new
    first_week = Hash.new
    second_week = Hash.new
    a = []
    week = {1 => 'monday', 2 => 'tuesday', 3 => 'wednesday', 4 => 'thursday', 5 => 'friday', 6 => 'saturday'}

    html = Nokogiri::HTML(page.body.force_encoding('UTF-8'))
    rasp = html.css('div.text-center')[0]

    if rasp.content.split("\r\n")[1].strip.split(' ')[0] == 'Нечётная'
      first_week['odd'] = true
      flag = true
    else
      first_week['odd'] = false
      flag = false
    end

    rasp = html.css('div.rasp-table-col')

    rasp.each do |div|
      answer = div.content.split("\r\n")
      answer.each do |i|
        answer[answer.index(i)] = i.strip
      end
      answer.delete_if(&:empty?)
      answer.delete_if{|i| i.include?':' }
      answer.delete_at(0)
      a.push(answer)
    end

    a[0..5].each do |list|
      dict = {}
      for i in [0, 2, 4, 6]
        dict[list[i]] = get_pairs(list[i+1])
      end
      first_week[week[a.find_index(list)+1]] = dict
    end

    if flag
      second_week['odd'] = false
    else
      second_week['odd'] = true
    end
    index = 0
    a[6..11].each do |list|
      dict = {}
      for i in [0, 2, 4, 6]
        dict[list[i]] = get_pairs(list[i+1])
      end
      second_week[week[index+1]] = dict
      index +=1
    end

    response['first'] = first_week
    response['second'] = second_week

    response.each do |w|
      w[1].each do |d|
        if d[1].is_a?Hash
          d[1].delete_if { |k,v| v.empty?}
        end
      end
    end
    response
  end

  def group_pars(agent, page, name)
    group = name
    page = agent.page.link_with(:text => group).click
    response = rasp_pars(page)
    response
  end

  def teacher_pars(agent, page, name)
    teacher = name
    teacher = teacher.split('')
    fio = []
    io = teacher[-2..-1]
    teacher.slice!(-3..-1)
    f = teacher.join('')
    fio.push(f)
    fio.push(io.join(''))
    teacher = fio.join(' ')
    page = agent.page.link_with(:text => teacher).click
    response = rasp_pars(page)
    response
  end

  def aud_pars(agent, page, name)
    data = name.split('/')
    aud_lists = []
    headers_list = []
    body_list = []
    aud_dict = {}
    #page = agent.page.link_with(:text => aud).click
    html = Nokogiri::HTML(page.body.force_encoding('UTF-8'))
    panels = html.css('div.panel')
    headers = panels.css('div.panel-heading')
    headers.each{|header| headers_list.push(header)}
    aud_lists.push(headers_list)
    bodys = panels.css('div.panel-body')
    h = {}
    bodys.xpath('//a[@href]').each do |link|
      h[link.text.strip] = link['href']
    end
    puts h
    bodys.each do |body|
      pp body.xpath('//a[@href]')
    end
    pp body_list
    aud_lists.push(body_list)
    i = 0
    while i < 12
      aud_dict[headers_list[i]] = body_list[i]
      i+=1
    end

    aud_dict.each do |k,v|
      if k.content.split(' ')[0].strip! == data[0]
        #s = v.css('div.col-kaf')
        #operat =
        puts
      end
    end

    response = rasp_pars(page)
    response
  end

  def main(name, group=false, teacher=false, auditory=false)
    agent = Mechanize.new
    if group
      page = agent.get('http://rasp.sstu.ru/')
      response = group_pars(agent, page, name)
    elsif teacher
      page = agent.get('http://rasp.sstu.ru/teacher')
      response = teacher_pars(agent, page, name)
    elsif auditory
      page = agent.get('http://rasp.sstu.ru/aud')
      response = aud_pars(agent, page, name)
    end
    #page = agent.page.link_with(:text => group).click
    hash = JSON["#{response.to_json}"]
    JSON.pretty_generate(hash)
  end
end

m = "1/411"
pars = Parser.new
puts pars.main(m.to_s, group=false, teacher=false, kafedra=true)

