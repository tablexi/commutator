module Commutator
  module Options
    class Query
      include Util::Fluent

      fluent_accessor :key_condition_expression,
                      :filter_expression,
                      :projection_expression,
                      :consistent_read,
                      :expression_attribute_values,
                      :expression_attribute_names,
                      :exclusive_start_key,
                      :index_name,
                      :return_consumed_capacity,
                      :scan_index_forward,
                      :select,
                      :table_name,
                      :limit

      fluent_wrapper :key_condition_expression,
                     :filter_expression,
                     :projection_expression,
                     :expression_attribute_values,
                     :expression_attribute_names,
                     :exclusive_start_key

      def initialize
        @expression_attribute_values ||= Expressions::AttributeValues.new
        @expression_attribute_names ||= Expressions::AttributeNames.new

        @key_condition_expression ||= Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)

        @filter_expression ||= Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)

        @projection_expression ||= Expressions::ProjectionExpression.new(
          attribute_names: @expression_attribute_names)
      end

      def asc
        scan_index_forward(true)
      end

      def desc
        scan_index_forward(false)
      end

      def to_h
        hash = {
          table_name: table_name,
          limit: limit,
          consistent_read: consistent_read,
          index_name: index_name,
          select: select,
          exclusive_start_key: exclusive_start_key,
          scan_index_forward: scan_index_forward,
          return_consumed_capacity: return_consumed_capacity,
          projection_expression: projection_expression.to_s,
          expression_attribute_names: expression_attribute_names.to_h,
          expression_attribute_values: expression_attribute_values.to_h,
          key_condition_expression: key_condition_expression.to_s(wrap: false),
          filter_expression: filter_expression.to_s(wrap: false)
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
    end
  end
end
