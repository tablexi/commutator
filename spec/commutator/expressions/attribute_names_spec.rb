require 'spec_helper'

RSpec.describe Commutator::Expressions::AttributeNames do
  subject(:names) { described_class.new }

  describe '#add' do
    context 'with a name that is a reserved word' do
      it 'adds a name' do
        names.add('count')

        expect(names.to_h)
          .to eq(Commutator::Util::Placeholders.name('count') => 'count')
      end
    end

    context 'with a name that is not a reserved word' do
      it 'does not add a name' do
        names.add('not_reserved')

        expect(names.to_h).to eq({})
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash of attribute names' do
      names.add('count')
      names.add('size')

      expected = {
        Commutator::Util::Placeholders.name('count') => 'count',
        Commutator::Util::Placeholders.name('size') => 'size'
      }

      expect(names.to_h).to eq(expected)
    end

    it 'returns a copy of the internal hash' do
      hash = names.to_h
      hash[:just_a_copy] = true

      expect(names.to_h).not_to eq(hash)
    end
  end
end
