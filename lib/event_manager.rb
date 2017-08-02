#!c:\Users/88630447753/Developer/RailsInstaller/Ruby2.3.0/bin/ruby
require "csv"
require "sunlight/congress" #an API to provide information on Members of USA Congress
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)   
#normalizing zipcodes
  zipcode.to_s.rjust(5,"0").slice(0,5)   
end

def legislator_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode) 

  legislator_names =legislators.collect do |legislator|
    "#{legislator.first_name} #{legislator.last_name}"
  end

  legislator_string = legislator_names.join(", ")

end

puts "EventManager Initialized!"

f_name = "event_attendees.csv"

contents = CSV.open(f_name, headers: true, header_converters: :symbol) if File.exist? f_name

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislator_by_zipcode(zipcode)

  form_letter = erb_template.result(binding) 
  puts form_letter
end   
   

