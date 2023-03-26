# frozen_string_literal: true

require_relative '../components/badger'

module NitroxCoreInternal
  module HistoryController
    HISTORY_SIZE = 5

    def self.item_key(topic, headers)
      "#{headers['Nitrox-Connection-Id'].split('@').last}/#{topic}/#{headers['Idempotency-Key']}"
    end

    def self.index_key(topic, headers)
      "#{headers['Nitrox-Connection-Id'].split('@').last}/#{topic}/index"
    end

    def self.add(topic, headers, data)
      item_key = self.item_key(topic, headers)
      index_key = self.index_key(topic, headers)

      return if Badger.instance.exists?(item_key)

      item = { created_at: Time.now, index: index_key, key: item_key, state: 'pending', data: data }

      Badger.instance.set(item_key, item)

      history = Badger.instance.get(index_key) || []

      history.prepend(item_key)

      history = history[0..HISTORY_SIZE - 1]

      Badger.instance.set(index_key, history)
    end

    def self.index(topic, headers)
      index_key = self.index_key(topic, headers)

      (Badger.instance.get(index_key) || []).map do |item_key|
        Badger.instance.get(item_key)
      end
    end

    def self.get(topic, headers)
      item_key = self.item_key(topic, headers)

      raise "key don't exists! #{item_key}" unless Badger.instance.exists?(item_key)
      
      Badger.instance.get(item_key)
    end

    def self.update(topic, headers, state, data)
      item_key = self.item_key(topic, headers)

      raise "key don't exists! #{item_key}" unless Badger.instance.exists?(item_key)
        
      item = Badger.instance.get(item_key)

      item[:state] = state
      item[state.to_sym] = { at: Time.now, data: data }

      Badger.instance.set(item_key, item)
    end
  end
end
