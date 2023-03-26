# frozen_string_literal: true

require 'dalli'
require 'singleton'

require_relative 'discovery'

class Cache
  include Singleton

  attr_reader :client

  def initialize
    @client = Dalli::Client.new(
      Discovery.instance.address('memcached'),
      { namespace: ENV.fetch('NITROX_SERVICE') }
    )
  end

  def build_key_for(key, params)
    return key unless params.size.positive?

    key_params = []
    params.keys.sort.each do |param_key|
      key_params << "#{param_key}:#{params[param_key]}"
    end
    "#{key}/#{key_params.sort.join(',')}"
  end

  def for(key, ttl: 1 * 60, params: {}, fresh: false, &block)
    key = build_key_for(key, params)

    cached_data = @client.get(key)

    return cached_data if cached_data && !fresh

    data = block.call

    @client.set(key, data, ttl) # ttl in seconds

    data
  end

  def wrapper
    Struct.new(:instance) do
      def get(...)
        instance.client.get(...)
      end

      def set(...)
        instance.client.set(...)
      end

      def flush(...)
        instance.client.flush(...)
      end

      def for(...)
        instance.for(...)
      end
    end.new(self)
  end
end
