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
  def get_pairs(string, is_room=false)
    dict = {}

    if string.nil? or string.length == 1
      dict
    else
      if not is_room
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
      else
        dict['subject'] = string.split(')')[0]<<')'
        lector_group = string.split(')').length == 2 ? string.split(')')[1] : string.split(')')[1..string.length-1].join(')')
        group = lector_group.split('-')[1].insert(0,'-')
        string[string.length-group.length..-1] = ''
        rev_string = string.split('').reverse
        a = 0
        rev_string.each do |i|
          if i.is_upper?
            a = rev_string.find_index(i)+1
            break
          end
        end
        if rev_string[a].is_lower?
          group.insert(0, rev_string[0..a].join('').reverse)
          rev_string[0..a] = ''
        else
          group.insert(0,rev_string[0])
          rev_string[0] = ''
        end
        lector = rev_string.join('').reverse
        lector[0..dict['subject'].length-1] = ''
        dict['group'] = group
        dict['lector'] = lector
      end
      dict
    end
  end

  def rasp_pars(page, is_aud=false)
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
        dict[list[i]] = get_pairs(list[i+1], is_aud)
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
        dict[list[i]] = get_pairs(list[i+1], is_aud)
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

  def lector_pars(agent, page, name)
    lector = name
    lector = lector.split('')
    fio = []
    io = lector[-2..-1]
    lector.slice!(-3..-1)
    f = lector.join('')
    fio.push(f)
    fio.push(io.join(''))
    lector = fio.join(' ')
    page = agent.page.link_with(:text => lector).click
    response = rasp_pars(page)
    response
  end

  def room_pars(agent, page, name)
    data = name.split('/')
    room_lists = []
    headers_list = []
    body_list = []
    room_dict = {}

    html = Nokogiri::HTML(page.body.force_encoding('UTF-8'))
    panels = html.css('div.panel')
    headers = panels.css('div.panel-heading')
    headers.each{|header| headers_list.push(header.text.strip)}
    room_lists.push(headers_list)
    bodys = panels.css('div.panel-body')

    bodys.each do |body|
      h = {}
      body.css('a[href]').each do |l|
        h[l.text] = l['href']
      end
      body_list.push(h)
      end

    room_lists.push(body_list)
    i = 0
    while i < 12
      room_dict[headers_list[i]] = body_list[i]
      i+=1
    end

    room_dict.each do |k,v|
      if k.split(' ')[0] == data[0]
        v.each do |a|
          if a[0] == data[1]
            page = agent.get('http://rasp.sstu.ru'+a[1])
          end
        end
      end
    end

    response = rasp_pars(page, is_aud=true)
    response
  end

  def main(name, group=false, lector=false, auditory=false, kafedra=false)
    agent = Mechanize.new
    if group
      page = agent.get('http://rasp.sstu.ru/')
      response = group_pars(agent, page, name)
    elsif lector
      page = agent.get('http://rasp.sstu.ru/teacher')
      response = lector_pars(agent, page, name)
    elsif auditory
      page = agent.get('http://rasp.sstu.ru/aud')
      response = room_pars(agent, page, name)
    #elsif kafedra
    #  response = Parser_kafed.new.main(name)
    end
    hash = JSON["#{response.to_json}"]
    JSON.pretty_generate(hash)
  end
end
