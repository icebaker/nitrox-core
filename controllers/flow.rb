# frozen_string_literal: true

require_relative 'history'

module NitroxCoreInternal
  module FlowController

    def self.to_fleeting(topic, item)
      fleeting = {
          _key: Digest::SHA256.hexdigest(item[:key]),
          _fleeting: true,
          topic: topic,
          at: item[:created_at],
          state: item[:state],
          idempotency_key: item[:data][:headers][:'Idempotency-Key'],
        }

        if fleeting[:state] == 'error'
          fleeting[:error] = item[:error][:data][:error].reject do |key, _|
            [:backtrace, :result].include?(key)
          end
        elsif fleeting[:state] == 'pending'
          fleeting[:request] = item[:data][:body]
        end

        fleeting
    end

    def self.fleeting(topic, headers)
      self.history(topic, headers).map do |item|
        to_fleeting(topic, item)
      end.filter { |item| item[:state] != 'success' }
    end

    def self.history(topic, headers)
      HistoryController.index(topic, headers)
    end

    def self.state(topic, headers)
      to_fleeting(topic, HistoryController.get(topic, headers))
    end

    def self.request(topic, headers, body)
      message = {
        headers: {
          'Idempotency-Key': headers['Idempotency-Key'],
          'Nitrox-Connection-Id': headers['Nitrox-Connection-Id']
        },
        body:
      }

      Redpanda.produce!(topic, message)

      HistoryController.add(topic, headers, message)

      { status: 202, body: message }
    end

    def self.perform(topic, message, &block)
      idempotency_key = message['headers']['Idempotency-Key']

      raise "already performed #{idempotency_key}" if NitroxCore.badger.exists?(idempotency_key)

      connection = message['headers']['Nitrox-Connection-Id']

      NitroxCore.lighstorm.ensure!(connection)

      NitroxCore.badger.set(idempotency_key, true)

      success(topic, message, block.call(connection, message['body']))
    rescue StandardError => e
      error(topic, message, e)
    end

    def self.success(topic, message, result)
      success_message = { request: message, action: result.to_h }

      Redpanda.produce!("#{topic}.success", success_message)

      HistoryController.update(topic, message['headers'], 'success', success_message)

      NitroxCore.logger.info("#{topic}.success [#{message['headers']['Idempotency-Key']}]")
    end

    def self.error(topic, message, e)
      if e.respond_to?(:to_h)
        error = e.to_h
      else
        error = { class: e.class.to_s, message: e.message, backtrace: e.backtrace }
      end

      error_message = { message:, error: }

      Redpanda.produce!("#{topic}.error", error_message)

      HistoryController.update(topic, message['headers'], 'error', error_message)

      NitroxCore.logger.info("#{topic}.error [#{message['headers']['Idempotency-Key']}] #{e}")
      raise e
    end
  end
end
