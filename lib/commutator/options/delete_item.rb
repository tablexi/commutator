module Commutator
  module Options
    class DeleteItem
      include Util::Fluent

      fluent_accessor :key,
                      :condition_expression,
                      :expression_attribute_names,
                      :expression_attribute_values,
                      :table_name,
                      :return_values,
                      :return_consumed_capacity,
                      :return_item_collection_metrics

      fluent_wrapper :key,
                     :condition_expression,
                     :expression_attribute_names,
                     :expression_attribute_values

      def initialize
        @key = {}

        @expression_attribute_names = Expressions::AttributeNames.new
        @expression_attribute_values = Expressions::AttributeValues.new

        @condition_expression = Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)
      end

      def to_h
        hash = {
          key: key,
          table_name: table_name,
          return_values: return_values,
          return_consumed_capacity: return_consumed_capacity,
          return_item_collection_metrics: return_item_collection_metrics,
          expression_attribute_names: expression_attribute_names.to_h,
          expression_attribute_values: expression_attribute_values.to_h,
          condition_expression: condition_expression.to_s(wrap: false)
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
      alias :to_hash :to_h
    end
  end
end
