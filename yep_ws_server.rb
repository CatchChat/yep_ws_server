require_relative 'config/environment'
require_relative 'lib/app'
Faye::WebSocket.load_adapter('goliath')

class YepWSServer < Goliath::API
  def response(env)
    App.call(env)
  end
end
