require 'net/http'
require 'uri'
require 'json'

# Define server URL
SERVER_URL = 'http://localhost:4567'

#Method to get the list of available slots
def fetch_available_slots
  #To parse the string formed by concatenating the SERVER_URL constant and the '/available_slots' endpoint into a URI::HTTP object 
  uri = URI.parse("#{SERVER_URL}/available_slots")
  #Initialise HTTP connection with the specified port and host
  http = Net::HTTP.new(uri.host, uri.port)
  #To construct a GET request object that can be sent to a server to retrieve information
  request = Net::HTTP::Get.new(uri.request_uri)
  #Sends the HTTP request represented by the request object to the server specified by the http 
  response = http.request(request)
  
  if response.code == '200'
    #Parses the JSON response body received from the server and extracts the value associated with the key 'available_slots'
    available_slots = JSON.parse(response.body)['available_slots']
    puts "Available Slots:"
    #To move through all the slots available
    available_slots.each do |slot|
      puts "Start Time: #{slot['start_time']}, End Time: #{slot['end_time']}"
    end
  else
    puts 'Failed to fetch available slots'
  end
end

# Method to execute a POST request to book a slot with patient info
def book_slot(start_time, end_time, patient_name, mobile_number, place, email)
  #To parse the string formed by concatenating the SERVER_URL constant and the '/available_slots' endpoint into a URI::HTTP object 
  uri = URI.parse("#{SERVER_URL}/book_slot")
  #Initialise HTTP connection with the specified port and host
  http = Net::HTTP.new(uri.host, uri.port)
  #To construct a POST request object that can be sent to a server to store information
  request = Net::HTTP::Post.new(uri.request_uri)
  request['Content-Type'] = 'application/json'
  #To add patient's info to the body
  request.body = {
    start_time: start_time,
    end_time: end_time,
    patient_name: patient_name,
    mobile_number: mobile_number,
    place: place,
    email: email
  }.to_json
  #Sends the HTTP request represented by the request object to the server specified by the http 
  response = http.request(request)
  #puts response.body 
  puts JSON.parse(response.body)["message"] 
  
end

#Method to edit the booked slot
def edit_booked_slot(email, edit_start_time, edit_end_time, edit_patient_name, edit_mobile_number, edit_place)
  uri = URI.parse("http://localhost:4567/edit_appointment/#{email}")
  #Initialise HTTP connection with the specified port and host
  http = Net::HTTP.new(uri.host, uri.port)
  #To construct a PUT request object that can be sent to a server to change information
  request = Net::HTTP::Put.new(uri.request_uri)
  request['Content-Type'] = 'application/json'
  #To add the edited patient's info to the body
  request.body = {
    'start_time' => edit_start_time,
    'end_time' => edit_end_time,
    'patient_name' => edit_patient_name,
    'mobile_number' => edit_mobile_number,
    'place' => edit_place
  }.to_json
  #Sends the HTTP request represented by the request object to the server specified by the http 
  response = http.request(request)
  
  if response.code == '200'
    puts 'Slot edited successfully'
  else
    puts 'Failed to edit slot'
  end
end

#Method to delete the booked appointment
def delete_appointment(email)
  uri = URI("http://localhost:4567/delete_appointment/#{email}")
  http = Net::HTTP.new(uri.host, uri.port)
  #To construct a DELETE request object that can be sent to a server to delete the appointment
  request = Net::HTTP::Delete.new(uri.request_uri)
  #Sends the HTTP request represented by the request object to the server specified by the http 
  response = http.request(request)

  if response.code == '200'
    puts 'Appointment deleted successfully'
  else
    puts 'Failed to delete appointment'
  end
end


loop do
  #Options available to choose for the user
  puts "1. Show slots "
  puts "2. Book slots "
  puts "3. Update slots "
  puts "4. Delete slots "
  option = nil
  option = gets.strip().to_i
  if option==1
    fetch_available_slots
  elsif option==2
    puts "Enter start time : "
    start_time= gets.strip()
    puts "Enter end time : "
    end_time= gets.strip()
    puts "Enter your name : "
    patient_name= gets.strip()
    puts "Enter your mobile number : "
    mobile_number= gets.strip()
    puts "Enter your place : "
    place= gets.strip()
    puts "Enter your email : "
    email= gets.strip()

    book_slot(start_time, end_time, patient_name, mobile_number, place, email)
  elsif option==3
    puts "Enter your email : "
    email= gets.strip()
    puts "Enter start time : "
    edit_start_time= gets.strip()
    puts "Enter end time : "
    edit_end_time= gets.strip()
    puts "Enter your name : "
    edit_patient_name= gets.strip()
    puts "Enter your mobile number : "
    edit_mobile_number= gets.strip()
    puts "Enter your place : "
    edit_place= gets.strip()

    edit_booked_slot(email, edit_start_time, edit_end_time, edit_patient_name, edit_mobile_number, edit_place)
  elsif option==4
    puts "Enter your email : "
    email= gets.strip()
    
    delete_appointment(email)
  
  else
    "Invalid OPtion"
  end
end
  



  


