# frozen_string_literal: true

require_relative '../logic/json'

module NitroxCoreInternal
  module RodaController
    def self.safely_ensure_json(response, &block)
      block.call
    rescue StandardError => e
      response.status = 500

      {
        error: e.class,
        message: e.message,
        backtrace: e.backtrace,
        response: {
          status: NitroxCore::Helpers::JSONHelper.safe_generate(response.status),
          headers: NitroxCore::Helpers::JSONHelper.safe_generate(response.headers),
          body: NitroxCore::Helpers::JSONHelper.safe_generate(response.body)
        }
      }
    end

    def self.headers(request)
      request.env.select { |k, _v| k.start_with? 'HTTP_' }
             .transform_keys { |k| k.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-') }
    end
  end
end
