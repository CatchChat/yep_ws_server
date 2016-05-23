class FayeClient
  class Authentication
    def initialize(token)
      @token = token
    end

    def outgoing(message, callback)
      message['ext'] ||= {}
      message['ext']['access_token'] = @token
      message['ext']['version'] = ENV['FAYE_SERVER_VERSION']
      callback.call(message)
    end
  end

  def initialize(token)
    @client = Faye::Client.new(ENV['FAYE_SERVER_URL'])
    @client.add_websocket_extension(PermessageDeflate)
    @client.add_extension(Authentication.new(token))
  end

  def subscribe(user_id, &block)
    @client.subscribe "/v1/users/#{user_id}/messages", false, &block
  end

  def publish(data)
    @client.publish('/messages', data)
  end

  def disconnect
    @client.disconnect
  end
end
