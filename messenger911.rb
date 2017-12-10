require 'sinatra'
require 'facebook/messenger'

get '/' do
  "Hello Home"
end

get '/sf911' do
  if ENV['FB_CONFIG_TOKEN'] == params['hub.verify']
    puts "verified!"
    params['hub.challenge']
  else
    403
  end
end
