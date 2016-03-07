require 'spec_helper'

RSpec.describe Commutator::Options::PutItem do
  subject(:put_item) { described_class.new }

  describe '#item' do
    it 'has an item fluent accessor' do
      expect(put_item.item('name' => 'Cat')).to eq(put_item)
      expect(put_item.item).to eq('name' => 'Cat')
    end
  end

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(put_item.return_consumed_capacity('TOTAL')).to eq(put_item)
      expect(put_item.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#return_item_collection_metrics' do
    it 'has a return_item_collection_metrics fluent accessor' do
      expect(put_item.return_item_collection_metrics('SIZE')).to eq(put_item)
      expect(put_item.return_item_collection_metrics).to eq('SIZE')
    end
  end

  describe '#return_values' do
    it 'has a return_values fluent accessor' do
      expect(put_item.return_values('NONE')).to eq(put_item)
      expect(put_item.return_values).to eq('NONE')
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(put_item.table_name('datapoints')).to eq(put_item)
      expect(put_item.table_name).to eq('datapoints')
    end
  end

  describe '#condition_expression' do
    it 'has a condition_expression fluent accessor' do
      expect(put_item.condition_expression('example value')).to eq(put_item)
      expect(put_item.condition_expression).to eq('example value')
    end

    it 'has a default ConditionExpression' do
      expect(put_item.condition_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the PutItem expression_attribute_names/values' do
      expect(put_item.condition_expression.attribute_names)
        .to eq(put_item.expression_attribute_names)

      expect(put_item.condition_expression.attribute_values)
        .to eq(put_item.expression_attribute_values)
    end
  end

  describe '#expression_attribute_names' do
    it 'hash an expression_attribute_names fluent accessor' do
      expect(put_item.expression_attribute_names('example value'))
        .to eq(put_item)

      expect(put_item.expression_attribute_names).to eq('example value')
    end

    it 'has a default AttributeNames' do
      expect(put_item.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#expression_attribute_values' do
    it 'has an expression_attribute_values fluent accessor' do
      expect(put_item.expression_attribute_values('example value'))
        .to eq(put_item)

      expect(put_item.expression_attribute_values).to eq('example value')
    end

    it 'has a default AttributeValues' do
      expect(put_item.expression_attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      put_item
        .table_name('datapoints')
        .item('first_name' => 'Yo')
        .return_consumed_capacity('TOTAL')
        .return_item_collection_metrics('SIZE')
        .return_values('NONE')
        .with_condition_expression { |exp|
          exp.where('token_channel = :?', values: ['123/4'])
            .and('#? > :?', names: ['count'], values: [10])
        }

      expected = {
        condition_expression: put_item.condition_expression.to_s(wrap: false),
        expression_attribute_names: put_item.expression_attribute_names.to_h,
        expression_attribute_values: put_item.expression_attribute_values.to_h,
        item: { 'first_name' => 'Yo' },
        return_consumed_capacity: 'TOTAL',
        return_item_collection_metrics: 'SIZE',
        return_values: 'NONE',
        table_name: 'datapoints'
      }

      expect(put_item.to_h).to eq(expected)
    end

    it 'filters blank values' do
      put_item
        .table_name('datapoints')
        .item('greeting' => 'HELLO!')

      expected = {
        table_name: 'datapoints',
        item: { 'greeting' => 'HELLO!' }
      }

      expect(put_item.to_h).to eq(expected)
    end
  end
end
