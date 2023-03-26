# frozen_string_literal: true

require 'faraday'
require 'singleton'

class Discovery
  include Singleton

  attr_reader :addresses

  def initialize
    @addresses = {}
  end

  def broadcast!
    Thread.new do
      pending = true

      loop do
        begin
          Faraday.put(
            "http://#{ENV.fetch('NITROX_DISCOVERY')}/#{ENV.fetch('NITROX_SERVICE').sub('/', '-')}",
            "#{ENV.fetch('NITROX_HOST')}:#{ENV.fetch('NITROX_PORT')}"
          )
          if pending
            Log.instance.logger.info(
              "Broadasted: #{ENV.fetch('NITROX_SERVICE').sub('/',
                                                             '-')}[#{ENV.fetch('NITROX_HOST')}:#{ENV.fetch('NITROX_PORT')}]"
            )
            pending = false
          end
        rescue StandardError => e
          pending = true
          Log.instance.logger.error(
            "Failed to broadcast: #{e.message} | Trying again in 5 seconds..."
          )
        end

        sleep 5
      end
    end
  end

  def fetch(service)
    response = Faraday.get("http://#{ENV.fetch('NITROX_DISCOVERY')}/#{service}")
    @addresses[service] = JSON.parse(response.body)['address']
  end

  def address(service)
    @addresses[service] ||= fetch(service)
  end
end
