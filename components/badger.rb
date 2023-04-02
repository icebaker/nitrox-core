# frozen_string_literal: true

require 'faraday'
require 'singleton'

require_relative 'discovery'

class Badger
  include Singleton

  attr_reader :address

  def initialize
    @address = Discovery.instance.address('badger-db')
  end

  def digest(key)
    Digest::SHA256.hexdigest("#{ENV.fetch('NITROX_SERVICE')}:#{key}")
  end

  def get(key)
    response = Faraday.get("http://#{@address}/items/#{digest(key)}")
    return nil if response.status == 404
    return Marshal.load(response.body) if response.status == 200

    raise StandardError, "Badger Unexpected Status #{response.status}"
  end

  def exists?(key)
    response = Faraday.head("http://#{@address}/items/#{digest(key)}")
    return true if response.status == 204
    return false if response.status == 404

    raise StandardError, "Badger Unexpected Status #{response.status}"
  end

  def set(key, value)
    response = Faraday.put("http://#{@address}/items/#{digest(key)}", Marshal.dump(value))

    return true if [201, 204].include?(response.status)

    raise StandardError, "Badger Unexpected Status #{response.status}"
  end

  def delete(key)
    response = Faraday.delete("http://#{@address}/items/#{digest(key)}")

    return true if response.status == 204
    return nil if response.status == 404

    raise StandardError, "Badger Unexpected Status #{response.status}"
  end
end
