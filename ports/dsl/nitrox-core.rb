# frozen_string_literal: true

require_relative '../../components/api'
require_relative '../../components/badger'
require_relative '../../components/discovery'
require_relative '../../components/redpanda'
require_relative '../../components/log'
require_relative '../../components/cache'
require_relative '../../components/monitoring'

require_relative '../../controllers/lighstorm'
require_relative '../../controllers/roda'
require_relative '../../controllers/flow'

require_relative '../../models/rate'
require_relative '../../models/satoshis'

require_relative '../../static/spec'
require_relative '../../logic/json'
require_relative '../../logic/hash'

module NitroxCore
  def self.helpers
    Struct.new(:_) do
      def json
        NitroxCore::Helpers::JSONHelper
      end

      def hash
        NitroxCore::Helpers::HashHelper
      end
    end.new
  end

  def self.lighstorm
    NitroxCoreInternal::LighstormController
  end

  def self.roda
    NitroxCoreInternal::RodaController
  end

  def self.flow
    NitroxCoreInternal::FlowController
  end

  def self.api
    API
  end

  def self.monitoring
    Monitoring.instance
  end

  def self.badger
    Badger.instance
  end

  def self.cache
    Cache.instance.wrapper
  end

  def self.discovery
    Discovery.instance
  end

  def self.logger
    Log.instance.logger
  end

  def self.redpanda
    Redpanda.instance
  end

  def self.version
    Static::SPEC[:version]
  end
end
