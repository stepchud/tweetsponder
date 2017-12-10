require 'sinatra'
require 'facebook/messenger'

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
