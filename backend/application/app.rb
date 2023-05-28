require 'sinatra'
require 'redis'
require 'json'

redis = Redis.new(host: 'redis', port: 6379)

get '/' do
  "<h1>Yeah, it's apparently working, my friend! xD :) :p =)</h1>"
end

post '/store' do
  request.body.rewind
  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, { message: 'An invalid JSON was sent!' }.to_json
  end

  if !data.key?("message")
    halt 400, { message: 'The message is missing!' }.to_json
  end

  if !data.key?("password")
    halt 400, { message: 'The password is missing!' }.to_json
  end

  message = data['message']
  password = data['password']

  if !message || message == "" || !password || password == ""
    halt 400, { message: 'The message or the password can\'t be empty!' }.to_json
  end

  key = SecureRandom.hex(16)
  redis.set(key, message)
  
  { key: key }.to_json
end

patch '/retrieve' do
  request.body.rewind
  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, { message: 'An invalid JSON was sent!' }.to_json
  end

  if !data.key?("key")
    halt 400, { message: 'The key is missing!' }.to_json
  end

  if !data.key?("password")
    halt 400, { message: 'The password is missing!' }.to_json
  end

  key = data['key']
  password = data['password']

  message = redis.get(key)
  if !message
    status 404

    { message: "Sorry, the message wasn't found!" }.to_json
  else
    redis.del(key)

    { message: message }.to_json
  end
end

set :port, 3000