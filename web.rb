require 'sinatra'
#require 'keys'

get '/' do
  @api_token = "c6e933c1e6b37dcd85b9a0a929d0775d"
  @api_token + " is your API token."
end

post '/' do
  "Hello new information.  It's been a long time.  But I think we can put our differences behind us.  For science."
end
