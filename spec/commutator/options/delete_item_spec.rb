require 'spec_helper'

RSpec.describe Commutator::Options::DeleteItem do
  subject(:delete_item) { described_class.new }

  describe '#key' do
    it 'defaults to an empty hash' do
      expect(delete_item.key).to eq({})
    end

    it 'has a key fluent accessor' do
      expect(delete_item.key('example value')).to eq(delete_item)
      expect(delete_item.key).to eq('example value')
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(delete_item.table_name('test_table')).to eq(delete_item)
      expect(delete_item.table_name).to eq('test_table')
    end
  end

  describe '#return_item_collection_metrics' do
    it 'has a return_item_collection_metrics fluent accessor' do
      expect(delete_item.return_item_collection_metrics('SIZE'))
        .to eq(delete_item)

      expect(delete_item.return_item_collection_metrics).to eq('SIZE')
    end
  end

  describe '#return_values' do
    it 'has a return_values fluent accessor' do
      expect(delete_item.return_values('NONE')).to eq(delete_item)
      expect(delete_item.return_values).to eq('NONE')
    end
  end

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(delete_item.return_consumed_capacity('TOTAL')).to eq(delete_item)
      expect(delete_item.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#condition_expression' do
    it 'has a condition_expression fluent accessor' do
      expect(delete_item.condition_expression('example value'))
        .to eq(delete_item)

      expect(delete_item.condition_expression).to eq('example value')
    end

    it 'has a default ConditionExpression' do
      expect(delete_item.condition_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the DeleteItem expression_attribute_names/values' do
      expect(delete_item.condition_expression.attribute_names)
        .to eq(delete_item.expression_attribute_names)

      expect(delete_item.condition_expression.attribute_values)
        .to eq(delete_item.expression_attribute_values)
    end
  end

  describe '#expression_attribute_names' do
    it 'has an expression_attribute_names fluent accessor' do
      expect(delete_item.expression_attribute_names('example value'))
        .to eq(delete_item)

      expect(delete_item.expression_attribute_names).to eq('example value')
    end

    it 'has a default AttributeNames' do
      expect(delete_item.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#expression_attribute_values' do
    it 'has an expression_attribute_values fluent accessor' do
      expect(delete_item.expression_attribute_values('example value'))
        .to eq(delete_item)

      expect(delete_item.expression_attribute_values).to eq('example value')
    end

    it 'has a default AttributeValues' do
      expect(delete_item.expression_attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      delete_item
        .key('token_channel' => '123/4', 'ts' => 199)
        .table_name('datapoints')
        .return_consumed_capacity('TOTAL')
        .return_item_collection_metrics('SIZE')
        .return_values('NONE')
        .with_condition_expression do |exp|
          exp
            .where('token_channel = :?', values: ['123/4'])
            .and('#? > :?', names: ['count'], values: [10])
        end

      expected = {
        key: { 'token_channel' => '123/4', 'ts' => 199 },
        condition_expression: delete_item.condition_expression.to_s(wrap: false),
        expression_attribute_names: delete_item.expression_attribute_names.to_h,
        expression_attribute_values: delete_item.expression_attribute_values.to_h,
        return_consumed_capacity: 'TOTAL',
        return_item_collection_metrics: 'SIZE',
        return_values: 'NONE',
        table_name: 'datapoints'
      }

      expect(delete_item.to_h).to eq(expected)
    end

    it 'filters blank values' do
      delete_item
        .table_name('datapoints')
        .key('token_channel' => '123/4', 'ts' => 123)
        .return_values(false)

      expected = {
        table_name: 'datapoints',
        return_values: false,
        key: { 'token_channel' => '123/4', 'ts' => 123 }
      }

      expect(delete_item.to_h).to eq(expected)
    end
  end
end
