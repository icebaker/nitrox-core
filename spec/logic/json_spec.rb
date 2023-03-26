# frozen_string_literal: true

require 'json'

require_relative '../../logic/json'

RSpec.describe NitroxCore::Helpers::JSONHelper do
  describe '.safe_generate' do
    it 'safe generates' do
      expect(
        described_class.safe_generate({ a: 'b' })
      ).to eq('{"a":"b"}')

      expect do
        JSON.generate({ b: ['lorem'].pack('H*') })
      end.to raise_error JSON::GeneratorError

      expect(
        described_class.safe_generate({ b: ['?'].pack('H*') })
      ).to eq('{"b":{"!binary":"f0"}}')
    end
  end
end
