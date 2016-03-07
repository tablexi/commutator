require 'spec_helper'

RSpec.describe Commutator::Expressions::AttributeValues do
  subject(:values) { described_class.new }

  describe '#add' do
    it 'adds a value' do
      values.add(199)

      expect(values.to_h)
        .to eq(Commutator::Util::Placeholders.value(199) => 199)
    end
  end

  describe '#to_h' do
    it 'returns a hash of attribute values' do
      values.add(200)
      values.add('hi')

      expected = {
        Commutator::Util::Placeholders.value(200) => 200,
        Commutator::Util::Placeholders.value('hi') => 'hi'
      }

      expect(values.to_h).to eq(expected)
    end

    it 'returns a copy of the internal hash' do
      hash = values.to_h
      hash[:just_a_copy] = true

      expect(values.to_h).not_to eq(hash)
    end
  end
end
