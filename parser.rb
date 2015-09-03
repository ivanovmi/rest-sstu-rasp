require 'json'
require 'mechanize'
require 'net/https'
require 'nokogiri'
require 'unicode'

class String
  def is_upper?
    self == Unicode::upcase(self)
  end

  def is_lower?
    self == Unicode::downcase(self)
  end
end


def get_pairs(string)
  dict = {}
  if string.length == 1
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

response = Hash.new
first_week = Hash.new
second_week = Hash.new
agent = Mechanize.new
#group = gets.chomp
group = 'б1-ИВЧТ41'
page = agent.get('http://rasp.sstu.ru/')
page = agent.page.link_with(:text => group).click
html = Nokogiri::HTML(page.body.force_encoding('UTF-8'))
rasp = html.css('div.text-center')[0]

week = {1 => 'monday', 2 => 'tuesday', 3 => 'wednesday', 4 => 'thursday', 5 => 'friday', 6 => 'saturday'}

if rasp.content.split("\r\n")[1].strip.split(' ')[0] == 'Нечётная'
  first_week['odd'] = true
  flag = true
else
  first_week['odd'] = false
  flag = false
end
rasp = html.css('div.rasp-table-col')
a = []
rasp.each do |div|
  answer = div.content.split("\r\n")
  answer.each do |i|
    answer[answer.index(i)] = i.strip
  end
  answer.delete_if(&:empty?)
  #answer.delete_if{|i| i.include?':' }
  answer.delete_at(0)
  a.push(answer)
end

# version with numbers
=begin
a[0..5].each do |list|
  dict = {}
  for i in [0, 2, 4, 6]
    dict[list[i]] = get_pairs(list[i+1])
  end
  first_week[week[a.find_index(list)+1]] = dict
end
=end

# version with time
a[0..5].each do |list|
  dict = {}
  for i in [0, 4, 8, 12]
    dict[(list[i+1]+list[i+2]).gsub(' ', '')] = get_pairs(list[i+3])
  end
  first_week[week[a.find_index(list)+1]] = dict
end
pp first_week

if flag
  second_week['odd'] = false
else
  second_week['odd'] = true
end
index = 0
a[6..11].each do |list|
  dict = {}
  for i in [0, 4, 8, 12]
    dict[(list[i+1]+list[i+2]).gsub(' ', '')] = get_pairs(list[i+3])
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

pp response
