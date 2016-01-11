module Commutator
  module Options
    class GetItem
      include Util::Fluent

      fluent_accessor :key,
                      :projection_expression,
                      :expression_attribute_names,
                      :consistent_read,
                      :table_name,
                      :return_consumed_capacity

      fluent_wrapper :key,
                     :projection_expression,
                     :expression_attribute_names

      def initialize
        @key = {}

        @expression_attribute_names = Expressions::AttributeNames.new

        @projection_expression = Expressions::ProjectionExpression.new(
          attribute_names: @expression_attribute_names)
      end

      def to_h
        hash = {
          table_name: table_name,
          expression_attribute_names: expression_attribute_names.to_h,
          consistent_read: consistent_read,
          return_consumed_capacity: return_consumed_capacity,
          projection_expression: projection_expression.to_s,
          key: key
        }

        hash.keep_if { |_key, value| value.present? || value == false }
      end
      alias :to_hash :to_h
    end
  end
end
