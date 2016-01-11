module Commutator
  module Options
    class PutItem
      include Util::Fluent

      fluent_accessor :item,
                      :condition_expression,
                      :expression_attribute_names,
                      :expression_attribute_values,
                      :return_consumed_capacity,
                      :return_item_collection_metrics,
                      :return_values,
                      :table_name

      fluent_wrapper :item,
                     :condition_expression,
                     :expression_attribute_names,
                     :expression_attribute_values

      def initialize
        @expression_attribute_names ||= Expressions::AttributeNames.new
        @expression_attribute_values ||= Expressions::AttributeValues.new

        @condition_expression ||= Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)
      end

      def to_h
        hash = {
          condition_expression: condition_expression.to_s(wrap: false),
          expression_attribute_names: expression_attribute_names.to_h,
          expression_attribute_values: expression_attribute_values.to_h,
          item: item.to_h,
          return_consumed_capacity: return_consumed_capacity,
          return_item_collection_metrics: return_item_collection_metrics,
          return_values: return_values,
          table_name: table_name
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
    end
  end
end
