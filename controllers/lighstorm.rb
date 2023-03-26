# frozen_string_literal: true

module NitroxCoreInternal
  module LighstormController
    def self.ensure!(connection_id)
      if connection_id.nil? || connection_id.empty?
        raise 'missing Nitrox-Connection-Id'
      elsif connection_id.split('@').size != 2
        raise 'Failed to establish a connection with a node.'
      end

      connection = Lighstorm::Connection.for(connection_id)

      config = nil

      return unless connection.nil?

      config = NitroxCore.helpers.hash.symbolize_keys(
        NitroxCore.api.fetch('nitrox-proxy', "/nitrox-connector/connections/#{connection_id}")
      )

      Lighstorm::Connection.add!(connection_id, **config.slice(:address, :certificate, :macaroon))
    end
  end
end
