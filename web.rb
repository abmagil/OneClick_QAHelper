require 'sinatra'

get '/' do
  @token + " is your API token."
end

post '/' do
  "Hello new information.  It's been a long time.  But I think we can put our differences behind us.  For science."
end
