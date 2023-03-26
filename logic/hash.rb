# frozen_string_literal: true

module NitroxCore
  module Helpers
    module HashHelper
      def self.symbolize_keys(object)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[key.to_sym] = symbolize_keys(value)
          end
        when Array
          object.map { |e| symbolize_keys(e) }
        else
          object
        end
      end
    end
  end
end
