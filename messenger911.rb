require 'sinatra'
require 'json'
require 'httparty'

CHATS = {}

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
  @message_body = JSON.parse(request.body.string)
  puts @message_body
  CHATS[sender_id] ||= {messages:[]}
  CHATS[sender_id][:messages] << message_text
  HTTParty.post(response_url, body: response(message_text))
  200
end

private

def response_url
  "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}"
end

def messaging
  @message_body["entry"]["messaging"].first
end

def message_text
  messaging["message"]["text"]
end

def sender_id
  messaging["sender"]["id"]
end

def fb_user
  "https://wwww.facebook.com/#{sender_id}"
end

def response text
  {
    "recipient": {"id": sender_id},
    "message": {"text": text}
  }
end
