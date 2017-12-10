require 'sinatra'
require 'facebook/messenger'

get '/' do
  "Hello Homie"
end

get '/sf911' do
  puts "params=#{params}"
  puts "ENV=#{ENV.to_h}"
  return params
  puts ENV['FB_CONFIG_TOKEN']
  if ENV['FB_CONFIG_TOKEN'] == params['hub.verify']
    puts "verified!"
    params['hub.challenge']
  else
    403
  end
end
