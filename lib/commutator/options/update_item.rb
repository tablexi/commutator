module Commutator
  module Options
    class UpdateItem
      include Util::Fluent

      fluent_accessor :key,
                      :expression_attribute_names,
                      :expression_attribute_values,
                      :update_expression,
                      :condition_expression,
                      :return_values,
                      :return_consumed_capacity,
                      :return_item_collection_metrics,
                      :table_name

      fluent_wrapper :key,
                     :expression_attribute_names,
                     :expression_attribute_values,
                     :update_expression,
                     :condition_expression

      def initialize
        @key = {}

        @expression_attribute_names = Expressions::AttributeNames.new
        @expression_attribute_values = Expressions::AttributeValues.new

        @update_expression = Expressions::UpdateExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)

        @condition_expression = Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)
      end

      def to_h
        hash = {
          key: key,
          expression_attribute_names: expression_attribute_names.to_h,
          expression_attribute_values: expression_attribute_values.to_h,
          condition_expression: condition_expression.to_s(wrap: false),
          update_expression: update_expression.to_s,
          return_values: return_values,
          return_consumed_capacity: return_consumed_capacity,
          return_item_collection_metrics: return_item_collection_metrics,
          table_name: table_name
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
      alias :to_hash :to_h
    end
  end
end
