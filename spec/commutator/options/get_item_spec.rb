require 'spec_helper'

RSpec.describe Commutator::Options::GetItem do
  subject(:get_item) { described_class.new }

  describe '#key' do
    it 'defaults to an empty hash' do
      expect(get_item.key).to eq({})
    end

    it 'has a key fluent accessor' do
      expect(get_item.key('abc' => '123')).to eq(get_item)
      expect(get_item.key).to eq('abc' => '123')
    end
  end

  describe '#consistent_read' do
    it 'has a consistent_read fluent accessor' do
      expect(get_item.consistent_read(true)).to eq(get_item)
      expect(get_item.consistent_read).to eq(true)
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(get_item.table_name('test_table')).to eq(get_item)
      expect(get_item.table_name).to eq('test_table')
    end
  end

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(get_item.return_consumed_capacity('TOTAL')).to eq(get_item)
      expect(get_item.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#projection_expression' do
    it 'has a projection_expression fluent accessor' do
      expect(get_item.projection_expression('example value')).to eq(get_item)
      expect(get_item.projection_expression).to eq('example value')
    end

    it 'has a default ProjectionExpression' do
      expect(get_item.projection_expression)
        .to be_a(Commutator::Expressions::ProjectionExpression)
    end

    it 'uses the GetItem expression_attribute_names' do
      expect(get_item.projection_expression.attribute_names)
        .to eq(get_item.expression_attribute_names)
    end
  end

  describe '#expression_attribute_names' do
    it 'has a expression_attribute_names fluent accessor' do
      expect(get_item.expression_attribute_names('example value'))
        .to eq(get_item)

      expect(get_item.expression_attribute_names).to eq('example value')
    end

    it 'has a default AttributeNames' do
      expect(get_item.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      get_item
        .table_name('datapoints')
        .consistent_read(false)
        .key('some_hash_key' => '1234455', 'some_range_key' => 234_234)
        .with_projection_expression { |exp|
          exp.path('token_channel')
            .path('#?', names: ['count'])
        }

      expected = {
        table_name: 'datapoints',
        consistent_read: false,
        key: { 'some_hash_key' => '1234455', 'some_range_key' => 234_234 },
        projection_expression: get_item.projection_expression.to_s,
        expression_attribute_names: get_item.expression_attribute_names.to_h
      }

      expect(get_item.to_h).to eq(expected)
    end

    it 'filters out blank values' do
      get_item
        .table_name('datapoints')
        .key('some_hash_key' => '123', 'some_range_key' => 123)

      expected = {
        table_name: 'datapoints',
        key: { 'some_hash_key' => '123', 'some_range_key' => 123 }
      }

      expect(get_item.to_h).to eq(expected)
    end
  end
end
