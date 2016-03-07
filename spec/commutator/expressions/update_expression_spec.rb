require 'spec_helper'

RSpec.describe Commutator::Expressions::UpdateExpression do
  subject(:expression) { described_class.new }

  let(:placeholder) { Commutator::Util::Placeholders }

  describe '#new' do
    it 'accepts attribute_names/values' do
      exp = described_class.new(attribute_names: 'NAMES!',
                                attribute_values: 'VALUES!')

      expect(exp.attribute_names).to eq('NAMES!')
      expect(exp.attribute_values).to eq('VALUES!')
    end
  end

  describe '#attribute_names' do
    it 'has default AttributeNames' do
      expect(expression.attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end

    # TODO: Spec for registering attribute names
  end

  describe '#attribute_values' do
    it 'has default AttributeValues' do
      expect(expression.attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end

    # TODO: Spec for registering attribute values
  end

  describe '#set' do
    it 'adds actions to the SET section' do
      expression
        .set('#? = #? + :?', names: %w(count count), values: [100])
        .set('first_name = :?', values: %w(Bro))

      expected = "SET #{placeholder.name('count')} = #{placeholder.name('count')} + #{placeholder.value(100)}, " \
                 "first_name = #{placeholder.value('Bro')}"

      expect(expression.to_s).to eq(expected)
    end
  end

  describe '#remove' do
    it 'adds actions to the REMOVE section' do
      expression
        .remove('friends[2]')
        .remove('#?', names: %w(count))

      expected = "REMOVE friends[2], #{placeholder.name('count')}"

      expect(expression.to_s).to eq(expected)
    end
  end

  describe '#add' do
    it 'adds actions to the ADD section' do
      expression
        .add('age :?', values: [10])
        .add('#? :?', names: %w(count), values: [100])

      expected = "ADD age #{placeholder.value(10)}, " \
                 "#{placeholder.name('count')} #{placeholder.value(100)}"

      expect(expression.to_s).to eq(expected)
    end
  end

  describe '#DELETE' do
    it 'adds actions to the DELETE section' do
      expression
        .delete('something :?', values: [1])

      expected = "DELETE something #{placeholder.value(1)}"

      expect(expression.to_s).to eq(expected)
    end
  end

  describe '#to_s' do
    it 'renders a full expression' do
      expression
        .set('something = :?', values: [100])
        .remove('friends[2]')
        .add('#? :?', names: %w(count), values: [5])
        .delete('last_names :?', values: %w(Smith))

      expected = "SET something = #{placeholder.value(100)} " \
                 'REMOVE friends[2] ' \
                 "ADD #{placeholder.name('count')} #{placeholder.value(5)} " \
                 "DELETE last_names #{placeholder.value('Smith')}"

      expect(expression.to_s).to eq(expected)
    end
  end
end
