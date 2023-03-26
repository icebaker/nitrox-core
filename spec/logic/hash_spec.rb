# frozen_string_literal: true

require_relative '../../logic/hash'

RSpec.describe NitroxCore::Helpers::HashHelper do
  describe '.symbolize_keys' do
    it 'symbolizes keys' do
      expect(
        described_class.symbolize_keys({ 'a' => 'b', 'c' => { 'd' => 'e' } })
      ).to eq({ a: 'b', c: { d: 'e' } })
    end
  end
end
