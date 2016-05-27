require_relative 'faye_client'
class App
  class << self
    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, [], extensions: [PermessageDeflate], ping: INTERVAL)
        logger = env.logger
        faye_client = nil
        user_id = nil

        ws.on :open do |event|
          logger.info [:open, ws.url]
          user_id, token = parse_user_id_and_token_from_url(ws.url)

          if user_id && token && token.start_with?('bot')
            faye_client = FayeClient.new(token)
            subscription = faye_client.subscribe(user_id) do |message|
              logger.debug message
              ws.send(Faye.to_json(message))
            end

            subscription.errback do |error|
              logger.error "#{user_id}: [SUBSCRIBE FAILED] #{error.message}"
              ws.send(Faye.to_json({ message_type: :error, message: { error: error.message } }))
            end
          else
            ws.send(Faye.to_json({ message_type: :error, message: { error: 'WebSocket URL is invalid' } }))
            ws.close(4030, 'WebSocket URL is invalid')
          end
        end

        ws.on :message do |event|
          logger.debug [:message, event.data]
          data = MultiJson.load(event.data) rescue nil
          if data.nil?
            ws.send(Faye.to_json({ message_type: :error, message: { error: 'Invalid data' } }))
          else
            publication = faye_client.publish(data)
            publication.errback do |error|
              logger.error "#{user_id}: [PUBLISH FAILED] #{error.inspect}"
              ws.send(Faye.to_json({ message_type: :error, message: { error: error.inspect } }))
            end
          end
        end

        ws.on :close do |event|
          logger.info [:close, ws.url, event.code, event.reason]
          faye_client && faye_client.disconnect
          faye_client = nil
          ws = nil
        end

        ws.rack_response
      else
        [400, {'Content-Type' => 'text/plain'}, ['Bad request']]
      end
    end

    private

    def parse_user_id_and_token_from_url(url)
      URI.parse(url).path.sub('/websocket', '')[1..-1].split(':')
    end
  end
end
