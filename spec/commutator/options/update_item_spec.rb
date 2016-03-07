require 'spec_helper'

RSpec.describe Commutator::Options::UpdateItem do
  subject(:update_item) { described_class.new }

  describe '#return_consumed_capacity' do
    it 'has a return_consumed_capacity fluent accessor' do
      expect(update_item.return_consumed_capacity('TOTAL')).to eq(update_item)
      expect(update_item.return_consumed_capacity).to eq('TOTAL')
    end
  end

  describe '#return_item_collection_metrics' do
    it 'has a return_item_collection_metrics fluent accessor' do
      expect(update_item.return_item_collection_metrics('SIZE'))
        .to eq(update_item)

      expect(update_item.return_item_collection_metrics).to eq('SIZE')
    end
  end

  describe '#return_values' do
    it 'has a return_values fluent accessor' do
      expect(update_item.return_values('NONE')).to eq(update_item)
      expect(update_item.return_values).to eq('NONE')
    end
  end

  describe '#table_name' do
    it 'has a table_name fluent accessor' do
      expect(update_item.table_name('datapoints')).to eq(update_item)
      expect(update_item.table_name).to eq('datapoints')
    end
  end

  describe '#update_expression' do
    it 'has a default UpdateExpression' do
      expect(update_item.update_expression)
        .to be_a(Commutator::Expressions::UpdateExpression)
    end

    it 'uses the UpdateItem expression_attribute_names/values' do
      expect(update_item.update_expression.attribute_names)
        .to eq(update_item.expression_attribute_names)

      expect(update_item.update_expression.attribute_values)
        .to eq(update_item.expression_attribute_values)
    end
  end

  describe '#condition_expression' do
    it 'has a default ConditionExpression' do
      expect(update_item.condition_expression)
        .to be_a(Commutator::Expressions::ConditionExpression)
    end

    it 'uses the UpdateItem expression_attribute_names/values' do
      expect(update_item.condition_expression.attribute_names)
        .to eq(update_item.expression_attribute_names)

      expect(update_item.condition_expression.attribute_values)
        .to eq(update_item.expression_attribute_values)
    end
  end

  describe '#expression_attribute_names' do
    it 'has a default AttributeNames' do
      expect(update_item.expression_attribute_names)
        .to be_a(Commutator::Expressions::AttributeNames)
    end
  end

  describe '#expression_attribute_values' do
    it 'has a default AttributeValues' do
      expect(update_item.expression_attribute_values)
        .to be_a(Commutator::Expressions::AttributeValues)
    end
  end
end
