require 'spec_helper'

RSpec.describe Commutator::Options::Query do
  subject(:query) { described_class.new }

  describe '#filter_expression' do
    it 'has a filter_expression fluent accessor' do
      expect(query.filter_expression('example value')).to eq(query)
      expect(query.filter_expression).to eq('example value')
    end

    it 'has a default FilterExpression' do
      expect(query.filter_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the Query expression_attribute_names' do
      expect(query.filter_expression.attribute_names)
        .to eq(query.expression_attribute_names)
    end

    it 'uses the Query expression_attribute_values' do
      expect(query.filter_expression.attribute_values)
        .to eq(query.expression_attribute_values)
    end
  end

  describe '#projection_expression' do
    it 'has a projection_expression fluent accessor' do
      expect(query.projection_expression('example value')).to eq(query)
      expect(query.projection_expression).to eq('example value')
    end

    it 'has a default ProjectionExpression' do
      expect(query.projection_expression)
        .to be_a(Commutator::Expressions::ProjectionExpression)
    end

    it 'uses the Query expression_attribute_names' do
      expect(query.projection_expression.attribute_names)
        .to eq(query.expression_attribute_names)
    end
  end

  describe '#key_condition_expression' do
    it 'has a key_condition_expression fluent accessor' do
      expect(query.key_condition_expression('example value')).to eq(query)
      expect(query.key_condition_expression).to eq('example value')
    end

    it 'has a default ConditionExpression' do
      expect(query.key_condition_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the Query expression_attribute_names/values' do
      expect(query.key_condition_expression.attribute_names)
        .to eq(query.expression_attribute_names)

      expect(query.key_condition_expression.attribute_values)
        .to eq(query.expression_attribute_values)
    end
  end

  describe '#expression_attribute_names' do
    it 'has an expression_attribute_names fluent accessor' do
      expect(query.expression_attribute_names('example value')).to eq(query)
      expect(query.expression_attribute_names).to eq('example value')
    end

    it 'has a default AttributeNames' do
      expect(query.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#expression_attribute_values' do
    it 'has an expression_attribute_values fluent accessor' do
      expect(query.expression_attribute_values('example value')).to eq(query)
      expect(query.expression_attribute_values).to eq('example value')
    end

    it 'has a default AttributeValues' do
      expect(query.expression_attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end
  end

  describe '#consistent_read' do
    it 'has a consistent_read fluent accessor' do
      expect(query.consistent_read(true)).to eq(query)
      expect(query.consistent_read).to eq(true)
    end
  end

  describe '#exclusive_start_key' do
    it 'has an exclusive_start_key fluent accessor' do
      expect(query.exclusive_start_key('token_channel' => '123/4')).to eq(query)
      expect(query.exclusive_start_key).to eq('token_channel' => '123/4')
    end
  end

  describe '#index_name' do
    it 'has an index_name fluent accessor' do
      expect(query.index_name('index-name')).to eq(query)
      expect(query.index_name).to eq('index-name')
    end
  end

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(query.return_consumed_capacity('TOTAL')).to eq(query)
      expect(query.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#scan_index_forward' do
    it 'has a scan_index_forward fluent accessor' do
      expect(query.scan_index_forward(true)).to eq(query)
      expect(query.scan_index_forward).to eq(true)
    end
  end

  describe '#select' do
    it 'has a select fluent accessor' do
      expect(query.select('ALL_ATTRIBUTES')).to eq(query)
      expect(query.select).to eq('ALL_ATTRIBUTES')
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(query.table_name('test_table')).to eq(query)
      expect(query.table_name).to eq('test_table')
    end
  end

  describe '#limit' do
    it 'has a limit fluent accessor' do
      expect(query.limit(100)).to eq(query)
      expect(query.limit).to eq(100)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      query
        .table_name('datapoints')
        .with_filter_expression { |exp|
          exp.and('whatever <= :?', values: [456])
        }
        .with_projection_expression { |exp| exp.path('hello') }
        .consistent_read(true)
        .index_name('index-name')
        .return_consumed_capacity('TOTAL')
        .limit(100)
        .with_key_condition_expression { |exp|
          exp.where('token_channel = :?', values: [100])
            .and('ts > :?', values: [123])
        }

      expected = {
        table_name: 'datapoints',
        limit: 100,
        consistent_read: true,
        key_condition_expression: query.key_condition_expression.to_s(wrap: false),
        filter_expression: query.filter_expression.to_s(wrap: false),
        projection_expression: query.projection_expression.to_s,
        expression_attribute_values: query.expression_attribute_values.to_h,
        index_name: 'index-name',
        return_consumed_capacity: 'TOTAL'
      }

      expect(query.to_h).to eq(expected)
    end
  end
end
