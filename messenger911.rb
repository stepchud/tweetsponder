require 'sinatra'
require 'facebook-messenger'

get '/' do
  puts "Hello Home"
end

get '/sf911' do
  puts "Hello Responder!"
end
