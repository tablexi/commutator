require 'spec_helper'

RSpec.describe Commutator::Util::Placeholders do
  describe '.name' do
    it 'returns the name if the names is not a reserved word' do
      expect(described_class.name('count'))
        .to eq("#N_#{Digest::SHA1.hexdigest('count'.to_json).first(10)}")
    end

    it 'returns a name placeholder if the name is a reserved word' do
      expect(described_class.name('regular')).to eq('regular')
    end
  end

  describe '.value' do
    it 'returns a value placeholder' do
      expect(described_class.value(100))
        .to eq(":V_#{Digest::SHA1.hexdigest(100.to_json).first(10)}")
    end
  end
end
