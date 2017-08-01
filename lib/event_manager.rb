#!c:\Users/88630447753/Developer/RailsInstaller/Ruby2.3.0/bin/ruby
require "csv"
puts "EventManager Initialized!"

f_name = "event_attendees.csv"

contents = CSV.open(f_name, headers: true, header_converters: :symbol) if File.exist? f_name
contents.each do |row|
   name = row[:first_name]
   zipcode = row[:zipcode]
   
#normalizing zipcodes
   if zipcode.nil? 
     zipcode = "00000"   
   elsif zipcode.length < 5
      zipcode = zipcode.rjust 5, "0"
   elsif zipcode.length > 5 	  
     zipcode = zipcode[0..4]
   end
   
   puts "#{name} #{zipcode}"
end
   

