require 'sinatra'
require 'facebook/messenger'

get '/' do
  "Hello Home"
end

get '/sf911' do
  "Hello Responder!"
end
