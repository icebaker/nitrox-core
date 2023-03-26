# frozen_string_literal: true

require_relative '../../ports/dsl/nitrox-core'

RSpec.describe NitroxCore do
  describe 'helpers' do
    it 'provides json.safe_generate' do
      expect(
        described_class.helpers.json.safe_generate({ a: 'b' })
      ).to eq('{"a":"b"}')
    end

    it 'provides hash.symbolize_keys' do
      expect(
        described_class.helpers.hash.symbolize_keys({ 'a' => 'b' })
      ).to eq({ a: 'b' })
    end
  end
end
