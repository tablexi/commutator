module Commutator
  module Options
    class Scan
      include Util::Fluent

      fluent_accessor :expression_attribute_values,
                      :expression_attribute_names,
                      :filter_expression,
                      :projection_expression,
                      :consistent_read,
                      :exclusive_start_key,
                      :index_name,
                      :limit,
                      :select,
                      :return_consumed_capacity,
                      :segment,
                      :table_name,
                      :total_segments

      fluent_wrapper :expression_attribute_values,
                     :expression_attribute_names,
                     :filter_expression,
                     :projection_expression,
                     :exclusive_start_key

      def initialize
        @expression_attribute_values = Expressions::AttributeValues.new
        @expression_attribute_names = Expressions::AttributeNames.new

        @filter_expression = Expressions::ConditionExpression.new(
          attribute_names: @expression_attribute_names,
          attribute_values: @expression_attribute_values)

        @projection_expression = Expressions::ProjectionExpression.new(
          attribute_names: @expression_attribute_names)
      end

      def to_h
        hash = {
          projection_expression: projection_expression.to_s,
          expression_attribute_values: expression_attribute_values.to_h,
          expression_attribute_names: expression_attribute_names.to_h,
          filter_expression: filter_expression.to_s(wrap: false),
          consistent_read: consistent_read,
          exclusive_start_key: exclusive_start_key,
          index_name: index_name,
          limit: limit,
          select: select,
          return_consumed_capacity: return_consumed_capacity,
          table_name: table_name,
          total_segments: total_segments,
          segment: segment
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
      alias :to_hash :to_h
    end
  end
end
