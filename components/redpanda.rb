# frozen_string_literal: true

require 'singleton'
require 'rainbow'
require 'rdkafka'
require 'json'

require_relative '../logic/json'

require_relative 'monitoring'

class Redpanda
  include Singleton

  attr_reader :broker

  def initialize
    @redpanda_address = Discovery.instance.fetch('redpanda')

    @broker = Rdkafka::Config.new({ 'bootstrap.servers': @redpanda_address })

    @producers = {}
    @cosumer_groups = {}
  end

  def consumer_group(id, options = {})
    config = { 'bootstrap.servers': @redpanda_address, 'group.id': id }

    raise "invalid from [#{options[:from]}]" if options[:from] && !%w[beginning now].include?(options[:from])

    config['auto.offset.reset'] = 'earliest' if options[:from] == 'beginning'

    @cosumer_groups[id] ||= Rdkafka::Config.new(config)
  end

  def produce!(topic, message)
    topic = "#{ENV.fetch('NITROX_SERVICE').sub('/', '.')}.#{topic}"
    @producers[topic] = @broker.producer unless @producers[topic]
    Monitoring.instance.redpanda.out(topic) do
      @producers[topic].produce(
        topic:,
        payload: NitroxCore::Helpers::JSONHelper.safe_generate(message)
      )
    end
  end

  def ensure_topic!(topic_name)
    @broker.admin.create_topic(topic_name, 1, 1)
  end

  def start_consumer!(topic, handler, options = {})
    unless @cosumer_groups[topic]
      @cosumer_groups[topic] = consumer_group(
        ENV.fetch('NITROX_SERVICE').sub('/', '.'), options
      ).consumer
    end

    @cosumer_groups[topic].subscribe(topic)

    Thread.new do
      loop do
        puts Rainbow("Starting Consumer [#{topic}]").blue.to_s
        begin
          @cosumer_groups[topic].each do |message|
            Monitoring.instance.redpanda.in(topic) do
              handler.call(JSON.parse(message.payload), message)
            rescue StandardError => e
              puts "#{Rainbow("Handler Error [#{topic}]").red} #{e}"
            end
          end
        rescue Rdkafka::RdkafkaError => e
          puts "#{Rainbow("Consumer Failed [#{topic}]").orange} #{e}"
        end
        sleep 1
      end
    end
  end
end
