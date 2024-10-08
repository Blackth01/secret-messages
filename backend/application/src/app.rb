require 'sinatra/base'
require 'redis'
require 'json'

require_relative 'utils/crypt_manager'


class SecretMessages < Sinatra::Base

  use Rack::RewindableInput::Middleware

  def initialize
    super()
    @redis = Redis.new(host: 'redis', port: ENV.fetch('REDIS_PORT', 6379))
    @crypt_manager = CryptManager.new
  end

  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
            'Access-Control-Allow-Headers' => 'Authorization, Content-Type'
  end

  options '*' do
    response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS, PATCH'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, Origin'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end



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
      halt 400, {message: 'The message is missing!'}.to_json
    end

    if !data.key?("password")
      halt 400, {message: 'The password is missing!'}.to_json
    end

    message = data['message']
    password = data['password']

    if !message || message == "" || !password || password == ""
      halt 400, {message: 'The message or the password can\'t be empty!'}.to_json
    end

    if data.key?("expiration")
      expiration_in_seconds = data["expiration"]

      if !expiration_in_seconds.is_a? Integer
        begin
          expiration_in_seconds = Integer(expiration_in_seconds)
        rescue ArgumentError => e
          halt 400, {message: 'The expiration in seconds should be a number!'}.to_json
        end
      end

      if expiration_in_seconds < 0
        halt 400, {message: "The expiration in seconds should be more than 0!"}.to_json
      end
    end

    key = SecureRandom.hex(16)

    aes_key = @crypt_manager.derive_aes_key(password, key)

    message = @crypt_manager.encrypt(message, aes_key)

    if expiration_in_seconds > 0
      @redis.set(key, message, :ex => expiration_in_seconds)
    else
      @redis.set(key, message)
    end

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

    message = @redis.get(key)

    if !message
      status 404

      { message: "Sorry, the message wasn't found! It either expired or was already read" }.to_json
    else
      aes_key = @crypt_manager.derive_aes_key(password, key)

      begin
        decrypted = @crypt_manager.decrypt(message, aes_key)
      rescue OpenSSL::Cipher::CipherError => e
        halt 400, { message: 'Invalid password sent!' }.to_json
      end

      @redis.del(key)

      { message: decrypted }.to_json
    end
  end

end