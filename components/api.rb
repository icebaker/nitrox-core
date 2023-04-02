# frozen_string_literal: true

require 'faraday'

require_relative 'discovery'

module API
  def self.fetch(api, path, params = {}, timeout: nil)
    url = "http://#{Discovery.instance.address(api)}#{path}"

    url = "#{url}?#{params.keys.map { |key| "#{key}=#{params[key]}" }.join('&')}" if params.keys.size.positive?

    response = if timeout.nil?
                 Faraday.get(url)
               else
                 Faraday::Connection.new.get(url) { |request| request.options.timeout = timeout }
               end

    begin
      JSON.parse(response.body)
    rescue StandardError => e
      raise e.class, "#{e.message} -> #{url}"
    end
  end

  def self.put(api, path, params = {})
    url = "http://#{Discovery.instance.address(api)}"

    connection = Faraday.new(url:)

    response = connection.put(path) do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = JSON.generate(params)
    end

    JSON.parse(response.body)
  end
end
