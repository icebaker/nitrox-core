# frozen_string_literal: true

require 'uri'
require 'logger'
require 'singleton'

class Monitoring
  PORTS = %i[http redpanda grpc].freeze

  include Singleton

  def initialize
    @state = {
      service: ENV.fetch('NITROX_SERVICE'),
      boot: Time.now,
      last: nil,
      ports: {}
    }

    PORTS.each do |port|
      @state[:ports][port] = {
        summary: {
          last: nil,
          out: { last: nil, count: 0, time: { sum: 0.0, average: 0.0 } },
          in: { last: nil, count: 0, time: { sum: 0.0, average: 0.0 } }
        },
        out: {}, in: {}
      }
    end
  end

  def setup(route)
    route.get 'status' do
      @state
    end
  end

  def status
    @state
  end

  def metrify(port, direction, key, &block)
    unless @state[:ports][port][direction][key]
      @state[:ports][port][direction][key] =
        { count: 0, time: { sum: 0.0, average: 0.0 } }
    end

    @state[:ports][port][direction][key][:count] += 1
    @state[:ports][port][:summary][direction][:count] += 1

    starting = Time.now
    response = block.call
    ending = Time.now

    @state[:ports][port][direction][key][:time][:sum] += (ending - starting)

    @state[:ports][port][direction][key][:time][:average] = (
      @state[:ports][port][direction][key][:time][:sum] / @state[:ports][port][direction][key][:count]
    )

    @state[:ports][port][:summary][direction][:time][:sum] += (ending - starting)
    @state[:ports][port][:summary][direction][:time][:average] = (
      @state[:ports][port][:summary][direction][:time][:sum] /
      @state[:ports][port][:summary][direction][:count]
    )

    @state[:last] = starting
    @state[:ports][port][:summary][:last] = starting
    @state[:ports][port][:summary][direction][:last] = starting

    response
  end

  def http_in(request, options = {}, &)
    key = request.path

    if options[:pop]
      key = request.path.split('/')
      key = "#{key[0..key.size - 2].join('/')}/$"
    end

    metrify(:http, :in, key, &)
  end

  def http_out(service, path, &)
    metrify(:http, :out, "[#{service}]#{path.gsub(/\?.*/, '')}", &)
  end

  def redpanda_in(topic, &)
    metrify(:redpanda, :in, topic, &)
  end

  def redpanda_out(topic, &)
    metrify(:redpanda, :out, topic, &)
  end

  def http
    Struct.new(:monitoring) do
      def in(...)
        monitoring.http_in(...)
      end

      def out(...)
        monitoring.http_out(...)
      end
    end.new(self)
  end

  def redpanda
    Struct.new(:monitoring) do
      def in(...)
        monitoring.redpanda_in(...)
      end

      def out(...)
        monitoring.redpanda_out(...)
      end
    end.new(self)
  end
end
