require 'spec_helper'

RSpec.describe Commutator::Options::Scan do
  subject(:scan) { described_class.new }

  describe '#filter_expression' do
    it 'has a filter_expression fluent accessor' do
      expect(scan.filter_expression('example value')).to eq(scan)
      expect(scan.filter_expression).to eq('example value')
    end

    it 'has a default FilterExpression' do
      expect(scan.filter_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the Scan expression_attribute_names' do
      expect(scan.filter_expression.attribute_names)
        .to eq(scan.expression_attribute_names)
    end

    it 'uses the Scan expression_attribute_values' do
      expect(scan.filter_expression.attribute_values)
        .to eq(scan.expression_attribute_values)
    end
  end

  describe '#projection_expression' do
    it 'has a projection_expression fluent accessor' do
      expect(scan.projection_expression('example value')).to eq(scan)
      expect(scan.projection_expression).to eq('example value')
    end

    it 'has a default ProjectionExpression' do
      expect(scan.projection_expression)
        .to be_a(Commutator::Expressions::ProjectionExpression)
    end

    it 'uses the Scan expression_attribute_names' do
      expect(scan.projection_expression.attribute_names)
        .to eq(scan.expression_attribute_names)
    end
  end

  describe '#expression_attribute_names' do
    it 'has an expression_attribute_names fluent accessor' do
      expect(scan.expression_attribute_names('example value')).to eq(scan)
      expect(scan.expression_attribute_names).to eq('example value')
    end

    it 'has a default AttributeNames' do
      expect(scan.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#expression_attribute_values' do
    it 'has an expression_attribute_values fluent accessor' do
      expect(scan.expression_attribute_values('example value')).to eq(scan)
      expect(scan.expression_attribute_values).to eq('example value')
    end

    it 'has a default AttributeValues' do
      expect(scan.expression_attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end
  end

  describe '#consistent_read' do
    it 'has a consistent_read fluent accessor' do
      expect(scan.consistent_read(true)).to eq(scan)
      expect(scan.consistent_read).to eq(true)
    end
  end

  describe '#exclusive_start_key' do
    it 'has an exclusive_start_key fluent accessor' do
      expect(scan.exclusive_start_key('token_channel' => '123/4')).to eq(scan)
      expect(scan.exclusive_start_key).to eq('token_channel' => '123/4')
    end
  end

  describe '#index_name' do
    it 'has an index_name fluent accessor' do
      expect(scan.index_name('index-name')).to eq(scan)
      expect(scan.index_name).to eq('index-name')
    end
  end

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(scan.return_consumed_capacity('TOTAL')).to eq(scan)
      expect(scan.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#segment' do
    it 'has a segment fluent accessor' do
      expect(scan.segment(1)).to eq(scan)
      expect(scan.segment).to eq(1)
    end
  end

  describe '#total_segments' do
    it 'has a total_segments accessor' do
      expect(scan.total_segments(100)).to eq(scan)
      expect(scan.total_segments).to eq(100)
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(scan.table_name('test_table')).to eq(scan)
      expect(scan.table_name).to eq('test_table')
    end
  end

  describe '#limit' do
    it 'has a limit fluent accessor' do
      expect(scan.limit(100)).to eq(scan)
      expect(scan.limit).to eq(100)
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      scan
        .table_name('datapoints')
        .consistent_read(false)
        .limit(100)
        .segment(19)
        .total_segments(300)
        .with_filter_expression { |exp|
          exp.where('token_channel = :?', values: [1])
            .and('#? > :?', names: %w(count), values: [10])
        }

      expected = {
        table_name: 'datapoints',
        consistent_read: false,
        limit: 100,
        segment: 19,
        total_segments: 300,
        filter_expression: scan.filter_expression.to_s(wrap: false),
        expression_attribute_values: scan.expression_attribute_values.to_h,
        expression_attribute_names: scan.expression_attribute_names.to_h
      }

      expect(scan.to_h).to eq(expected)
    end
  end
end
