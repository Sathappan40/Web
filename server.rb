require 'sinatra'
require 'mysql2'
require 'json'

# Configuration for MySQL connection
configure do
  set :mysql_host, 'localhost'
  set :mysql_username, 'root'
  set :mysql_password, 'Karthi@2002'
  set :mysql_database, 'hospital_appointment'
end

# Establish MySQL connection
def connect_to_database
  Mysql2::Client.new(host: settings.mysql_host, username: settings.mysql_username, password: settings.mysql_password, database: settings.mysql_database)
end

# Endpoint to get available slots
get '/available_slots' do
  content_type :json
  
  begin
    client = connect_to_database
    # Query the database to get available slots
    results = client.query("SELECT * FROM availability_slots WHERE availability_status = true")
    #Maps the query results to an array of hashes, each representing a time slot with start_time and end_time
    slots = results.map { |row| { start_time: row['start_time'], end_time: row['end_time'] } }
    client.close
    { available_slots: slots }.to_json
  #If an exception occurs, it is caught by the rescue block
  #It sets the HTTP status code to 500 (Internal Server Error) 
  rescue Mysql2::Error => e
    status 500
    { error: e.message }.to_json
  end
end


# Endpoint to book a slot
post '/book_slot' do
  #Sets the response content type to JSON
  content_type :json
  #JSON data from the request body is parsed into a Ruby hash.
  request_body = JSON.parse(request.body.read)
  start_time = request_body['start_time']
  end_time = request_body['end_time']
  patient_name = request_body['patient_name']
  mobile_number = request_body['mobile_number']
  place = request_body['place']
  email = request_body['email']

  begin
    client = connect_to_database
    # Check if the slot is already booked
    existing_slot = client.query("SELECT * FROM availability_slots WHERE start_time = '#{start_time}' AND end_time = '#{end_time}' AND availability_status = false").first
    
    if !existing_slot.nil? && existing_slot["availability_status"]==0
      # Slot is already booked, return a message indicating it's already booked
      client.close
      return { message: "Slot is already booked" }.to_json
    end
    # Update the database to book the slot and store patient information
    client.query("UPDATE availability_slots SET availability_status = false, patient_name = '#{patient_name}', mobile_no = '#{mobile_number}', place = '#{place}', email = '#{email}' WHERE start_time = '#{start_time}' AND end_time = '#{end_time}' AND availability_status = true")
    client.close
    { message: "Slot booked successfully" }.to_json
  rescue Mysql2::Error => e
    status 500
    { error: e.message }.to_json
  end
end


# Endpoint to edit a booked appointment
put '/edit_appointment/:email' do
  # Connect to the database
  db = connect_to_database 
  #JSON data from the request body is parsed into a Ruby hash.
  appointment_details = JSON.parse(request.body.read)
  #Allows you to access the value of the email parameter passed in the URL
  email = params[:email]
  edit_start_time = appointment_details['start_time']
  edit_end_time = appointment_details['end_time']
  edit_patient_name = appointment_details['patient_name']
  edit_mobile_number = appointment_details['mobile_number']
  edit_place = appointment_details['place']

  # Fetch the existing appointment details from the database
  # Retrieves the first row returned by the SQL query
  existing_appointment = db.query("SELECT * FROM availability_slots WHERE email = '#{email}' AND availability_status = false").first
  
  # Check if the appointment exists
  if existing_appointment
    # Update the availability status of the original slot to make it available again
    db.query("UPDATE availability_slots SET availability_status = true, patient_name = NULL, mobile_no = NULL, place = NULL, email=NULL WHERE email = '#{email}'")
    
    # Book the new appointment slot with the updated details
    db.query("UPDATE availability_slots SET availability_status = false, patient_name = '#{edit_patient_name}', mobile_no = '#{edit_mobile_number}', place = '#{edit_place}', email = '#{email}' WHERE start_time = '#{edit_start_time}' AND end_time = '#{edit_end_time}' AND availability_status = true")
    
    status 200
  else
    # HTTP status code 404 is used to indicate that the requested resource was not found
    status 404
  end
end



#Endpoint to delete a booked slot
delete '/delete_appointment/:email' do
  # Implement code to delete a booked slot in the database based on the email as a token
  # Connect to the database
  db = connect_to_database 
  #Allows you to access the value of the email parameter passed in the URL
  email = params[:email]

  # Check if the appointment exists
  # Retrieves the first row returned by the SQL query
  existing_appointment = db.query("SELECT * FROM availability_slots WHERE email = '#{email}' AND availability_status = false").first

  if existing_appointment
    # Delete the appointment from the database
    db.query("UPDATE availability_slots SET availability_status = true, patient_name = NULL, mobile_no = NULL, place = NULL, email=NULL WHERE email = '#{email}'")
    status 200
  else
    # HTTP status code 404 is used to indicate that the requested resource was not found
    status 404
  end
end
