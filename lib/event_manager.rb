#!./Developer/RailsInstaller/Ruby2.3.0/bin/ruby
require "csv"
require "sunlight/congress" #an API to provide information on Members of USA Congress
require "erb"
require "chronic" 

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def time_target(date)
  return (Chronic.parse(date).hour)
end


def clean_phone(phone_number)
# get only numbers
  pn = phone_number.gsub(/[^\d]/,"")
# get numbers with size <= 11
  if pn =~ /^(\d{3,4})(\d{3})(\d{4})$/
    p1 = $1 #deal with 3 or 4 initial characters 
    p1.size == 4 ? (p1[0] == '1' ? p1 = p1.slice(1,4) : pn = "bad number") : p1	
    pn = "(#{p1})#{$2}-#{$3}" unless pn == "bad number"
  else
    pn = "bad number"
  end
  return pn  
end

def clean_zipcode(zipcode)   
#normalizing zipcodes
  zipcode.to_s.rjust(5,"0").slice(0,5)   
end

def legislator_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode) 
 end

def print_hash(hash)
  hash = hash.sort_by { |a,b| b}
  hash.reverse!
  hash.each { |hour, n| "#{hour.to_s} #{n.to_s}"}
end 

def save_form(id, form_letter)
  Dir.mkdir("output") unless Dir.exist? "output"
  filename = File.join("output","thanks_#{id}.html")
	
  File.open(filename,'w') do |file|
	file.puts form_letter	
  end
end 

def save_stat(template_statistics)
  Dir.mkdir("statistics") unless Dir.exist? "statistics"
  filename = File.join("statistics","statistics.html")
  
  File.open(filename,'w') { |file| file.puts template_statistics }
end
puts "EventManager Initialized!"

f_name = 'event_attendees.csv' 

contents = CSV.open(f_name, headers: true, header_converters: :symbol) if File.exist? f_name

template_letter = File.read("form_letter.erb")
template_statistics = File.read("statistics.erb")


erb_letter = ERB.new(template_letter)
erb_statistics = ERB.new(template_statistics)

reg_date = Hash.new(0) 
day_date = Hash.new(0)

contents.each do |row|
  id = row[0] 
  name = row[:first_name]
  date = row[:regdate]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number =  clean_phone(row[:homephone])
  legislators = legislator_by_zipcode(zipcode)
  reg_date[time_target(date)] +=1
  day_date[(Chronic.parse(date).day)] += 1
  template_letter = erb_letter.result(binding) 
  
  save_form(id, template_letter)
end 

template_statistics = erb_statistics.result(binding) 
save_stat(template_statistics)

=begin  
puts "Printing time"
print_hash(reg_date)   
puts "Printing day"
print_hash(day_date)   
=end

