require 'sinatra'
#require 'nokogiri'
require_relative 'keys'

get '/' do
  ENV['APIKEY'] + " is your token."
end

post '/' do
  "Hello new information.  It's been a long time.  But I think we can put our differences behind us.  For science."
end

