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
  user = HTTParty.get("https://graph.facebook.com/v2.6/#{sender_id}?fields=first_name,last_name,locale&access_token=#{access_token}").parsed_response
  @chat = Chat.new(sender_id, user)
  @chat.add_message message_text
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

def message_text
  messaging["message"]["text"]
end

def sender_id
  messaging["sender"]["id"]
end
