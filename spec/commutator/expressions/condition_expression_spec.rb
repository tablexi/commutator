require 'spec_helper'

RSpec.describe Commutator::Expressions::ConditionExpression do
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

  describe '#or' do
    it 'adds a statement with or' do
      expression
        .where('attribute_exists(ts)')
        .or('ts > :?', values: [100])

      expect(expression.to_s)
        .to eq("(attribute_exists(ts) OR ts > #{placeholder.value(100)})")
    end

    it 'adds an expression with OR' do
      expression.where('attribute_exists(ts)')

      expression.or do |exp|
        exp
          .where('#? > :?', names: ['count'], values: [123])
          .and('attribute_exists(abc)')
      end

      expect(expression.to_s)
        .to eq('(attribute_exists(ts) OR ' \
               "(#{placeholder.name('count')} > #{placeholder.value(123)} AND " \
               'attribute_exists(abc)))')
    end
  end

  describe '#or_not' do
    it 'adds a statement with OR NOT' do
      expression
        .where('attribute_exists(ts)')
        .or_not('ts > :?', values: [100])

      expect(expression.to_s)
        .to eq("(attribute_exists(ts) OR NOT ts > #{placeholder.value(100)})")
    end

    it 'adds an expression with OR NOT' do
      expression.where('attribute_exists(ts)')
      expression.or_not do |exp|
        exp
          .where('#? > :?', names: ['count'], values: [123])
          .and('attribute_exists(abc)')
      end

      expect(expression.to_s)
        .to eq('(attribute_exists(ts) OR NOT ' \
               "(#{placeholder.name('count')} > #{placeholder.value(123)} AND " \
               'attribute_exists(abc)))')
    end
  end

  describe '#and' do
    it 'adds a statement with AND' do
     expression
        .where('attribute_exists(ts)')
        .and('ts > :?', values: [100])

      expect(expression.to_s)
        .to eq("(attribute_exists(ts) AND ts > #{placeholder.value(100)})")
    end

    it 'adds an expression with AND' do
      expression.where('attribute_exists(ts)')
      expression.and do |exp|
        exp
          .where('#? > :?', names: ['count'], values: [123])
          .or('attribute_exists(abc)')
      end

      expect(expression.to_s)
        .to eq('(attribute_exists(ts) AND ' \
              "(#{placeholder.name('count')} > #{placeholder.value(123)} OR " \
               'attribute_exists(abc)))')
    end
  end

  describe '#and_not' do
    it 'adds a statement with AND NOT' do
      expression
        .where('attribute_exists(ts)')
        .and_not('ts > :?', values: [100])

      expect(expression.to_s)
        .to eq("(attribute_exists(ts) AND NOT ts > #{placeholder.value(100)})")
    end

    it 'adds an expression with AND' do
      expression.where('attribute_exists(ts)')
      expression.and_not do |exp|
        exp
          .where('#? > :?', names: ['count'], values: [123])
          .or('attribute_exists(abc)')
      end

      expect(expression.to_s)
        .to eq('(attribute_exists(ts) AND NOT ' \
               "(#{placeholder.name('count')} > #{placeholder.value(123)} OR " \
               'attribute_exists(abc)))')
    end
  end

  describe '#where' do
    it 'aliases and' do
      expect(expression.method(:where)).to eq(expression.method(:and))
    end
  end

  describe '#where_not' do
    it 'aliases and_not' do
      expect(expression.method(:where_not)).to eq(expression.method(:and_not))
    end
  end
end
