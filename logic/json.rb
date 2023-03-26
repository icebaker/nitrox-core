# frozen_string_literal: true

require 'json'

module NitroxCore
  module Helpers
    module JSONHelper
      def self.safe_generate(data)
        JSON.generate(data)
      rescue JSON::GeneratorError => _e
        JSON.generate(secure(Marshal.load(Marshal.dump(data))))
      end

      def self.secure(node)
        case node
        when Hash
          result = {}
          node.each_key { |key| result[key] = secure(node[key]) }
        when Array
          result = []
          node.each { |value| result << secure(value) }
        when String
          begin
            JSON.generate(node)
            result = node
          rescue JSON::GeneratorError => _e
            result = { '!binary': node.unpack1('H*') }
          end
        else
          result = node
        end

        result
      end
    end
  end
end
