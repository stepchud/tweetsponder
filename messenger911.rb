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
  CHATS[sender_id] ||= {messages:[]}
  puts "adding message #{message_text}"
  CHATS[sender_id][:messages] << message_text
  puts "POST #{response_url}"
  puts "response data: #{format_response(message_text)}"
  @response_result = HTTParty.post(
    response_url,
    headers: { 'Content-Type' => 'application/json' }
    body: format_response(message_text).to_json)
  puts "raw body: #{@response_result.response.body}"
  puts "parsed body: #{@response_result.parsed_response["data"]}"
  200
end

private

def response_url
  "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}"
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

def page_scoped_user
  "https://wwww.facebook.com/#{sender_id}"
end

def format_response text
  {
    "recipient": {"id": sender_id},
    "message": {"text": "Got your #{CHATS[sender_id][:messages].count} message: #{text}"}
  }
end
