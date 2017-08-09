#!./Developer/RailsInstaller/Ruby2.3.0/bin/ruby
require "csv"
require "sunlight/congress" #an API to provide information on Members of USA Congress
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_phone(phone_number)
# get only numbers
  pn = phone_number.gsub(/[^\d]/,"")
# get numbers with size <= 11
  if pn.length.between?(10,11) 
    pn.match(/^1/) ? (pn.length == 11 ? pn = pn.slice(1,11) : pn = "bad number") : pn
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

def save_form(id, form_letter)
  Dir.mkdir("output") unless Dir.exist? "output"
  filename = File.join("output","thanks_#{id}.html")
	
  File.open(filename,'w') do |file|
	file.puts form_letter	
  end
end 

puts "EventManager Initialized!"

f_name = 'event_attendees.csv' 

contents = CSV.open(f_name, headers: true, header_converters: :symbol) if File.exist? f_name

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0] 
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number =  clean_phone(row[:homephone])
  legislators = legislator_by_zipcode(zipcode)

  form_letter = erb_template.result(binding) 
  
  save_form(id, form_letter)
end   
   

