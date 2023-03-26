# frozen_string_literal: true

module NitroxCore
  module Models
    class Rate
      attr_reader :parts_per_million

      # https://en.wikipedia.org/wiki/Parts-per_notation
      def initialize(parts_per_million: nil)
        raise 'missing parts_per_million' if parts_per_million.nil?

        # TODO
        @parts_per_million = parts_per_million
      end

      def to_h
        {
          parts_per_million: @parts_per_million
          # satoshis: satoshis,
          # bitcoins: bitcoins
        }
      end
    end
  end
end
