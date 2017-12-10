require 'sinatra'
require 'json'
require 'httparty'
require './chat'

get '/' do
  "Hello Homie"
end

get '/sf911' do
  puts "params=#{params}"
  puts ENV['FB_VERIFY_TOKEN']
  if ENV['FB_VERIFY_TOKEN'] == params["hub.verify_token"]
    puts "verified!"
    params["hub.challenge"]
  else
    403
  end
end

post '/sf911' do
  @message_body = JSON.parse request.body.string
  puts "RECEIVED: #{@message_body}"
  user = HTTParty.get("https://graph.facebook.com/v2.6/#{sender_id}?fields=first_name,last_name,locale&access_token=#{access_token}").parsed_response
  @chat = Chat.new(sender_id, user)
  @chat.add_message message_data
  @response_result = HTTParty.post(
    response_url,
    headers: { 'Content-Type' => 'application/json' },
    body: @chat.get_response.to_json
  )
  puts "raw body: #{@response_result.response.body}"
  puts "parsed body: #{@response_result.parsed_response}"
  200
end

private

def access_token
  ENV['PAGE_ACCESS_TOKEN']
end

def response_url
  "https://graph.facebook.com/v2.6/me/messages?access_token=#{access_token}"
end

def messaging
  @message_body["entry"][0]["messaging"][0]
end

def message_data
  postback_data || location_data || message_text
end

def message_text
  if messaging["message"]["text"] =~ /\d+-\d+-\d+/
    {text: messaging["message"]["text"], phone_number:messaging["message"]["text"]}
  else
    {text: messaging["message"]["text"]}
  end
end

def postback_data
  if messaging["postback"]
    {text: messaging["postback"]["title"], postback: messaging["postback"]["payload"]}
  end
end

def location_data
  if messaging["message"]["attachments"] && messaging["message"]["attachments"][0]["type"]=="location"
    {text: messaging["message"]["attachments"][0]["title"], location: messaging["message"]["attachments"][0]["payload"]}
  end
end

def sender_id
  messaging["sender"]["id"]
end
