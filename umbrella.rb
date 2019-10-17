# In order for this program to work, you need to add a file called in the left sidebar called ".env" and in there you need to add these lines:
#
#     GOOGLE_API_KEY=blah
#     DARKSKY_API_KEY=blah
#     TWILIO_ACCOUNT_SID=blah
#     TWILIO_AUTH_TOKEN=blah
#     MAILGUN_API_KEY=blah
#     TWILIO_ASSIGNED_PHONE_NUMBER=blah
#     YOUR_PHONE_NUMBER=blah
#
#   You get these keys by signing up at the respective developer dashboards. Sending email with Mailgun is slightly involved, because you also need to purchase a domain and configure it. I recommend starting with sending text messages with Twilio.

puts "Enter your street address:"
# street_address = gets.chomp
street_address = "Merchandise Mart, Chicago"

puts "Okay, getting the weather forecast for " + street_address + "..."

##############################################
# Get lat/lng from Google Maps Geocoding API #
##############################################

gmaps_api_endpoint = "https://maps.googleapis.com/maps/api/geocode/json?address=" + street_address + "&key=" + ENV.fetch("GOOGLE_API_KEY")

require("open-uri")

raw_gmaps_data = open(gmaps_api_endpoint).read

require("json")

parsed_gmaps_data = JSON.parse(raw_gmaps_data)

results = parsed_gmaps_data.fetch("results")
first_result = results.at(0)
geo = first_result.fetch("geometry")
loc = geo.fetch("location")

latitude = loc.fetch("lat")
longitude = loc.fetch("lng")

puts "Your latitude is " + latitude.to_s
puts "Your longitude is " + longitude.to_s

##########################################
# Get weather forecast from Dark Sky API #
##########################################

forecast_api_endpoint = "https://api.darksky.net/forecast/" + ENV.fetch("DARKSKY_API_KEY") + "/" + latitude.to_s + "," + longitude.to_s

raw_forecast_data = open(forecast_api_endpoint).read
parsed_forecast_data = JSON.parse(raw_forecast_data)

current_temp = parsed_forecast_data.fetch("currently").fetch("temperature")

puts "Current temperature: " + current_temp.to_s

current_summary = parsed_forecast_data.fetch("currently").fetch("summary")

puts "Current summary: " + current_summary

minutely_summary = parsed_forecast_data.fetch("minutely").fetch("summary")

puts "For the next few minutes: " + minutely_summary

hourly_summary = parsed_forecast_data.fetch("hourly").fetch("summary")

puts "For the next few hours: " + hourly_summary

daily_summary = parsed_forecast_data.fetch("daily").fetch("summary")

puts "For the next few days: " + daily_summary

############################################
# Check whether or not to take an umbrella #
############################################

# If in the next 12 hours there is at least one hour in which it is likely (greater than 50% probability) to rain, then print a message saying "Take an umbrella with you!"

##############################
# Send an email notification #
##############################

require("mailgun-ruby")

mg_api_key = ENV.fetch("MAILGUN_API_KEY")

# First, instantiate the Mailgun Client with your API key
mg_client = Mailgun::Client.new(mg_api_key)

# Define your message parameters
email_parameters =  { 
  :from => "notifications@teacherplan.org",
  :to => "raghu@firstdraft.com",
  :subject => "Take an umbrella today!",
  :text => "It's going to rain today, take an umbrella with you!"
}

# Send your message through the client
mg_client.send_message("mg.teacherplan.org", email_parameters)

############################
# Send an SMS notification #
############################

require("twilio-ruby")

twilio_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
twilio_token = ENV.fetch("TWILIO_AUTH_TOKEN")

sms_parameters = {
  :from => ENV.fetch("TWILIO_ASSIGNED_PHONE_NUMBER"),
  :to => ENV.fetch("YOUR_PHONE_NUMBER"),
  :body => "It's going to rain today — take an umbrella!"
}

# Set up a client to talk to the Twilio REST API
twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

# Send your message through the client
twilio_client.api.account.messages.create(sms_parameters)
