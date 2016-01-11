module Commutator
  module Expressions
    # See: http://goo.gl/bhIUgS
    #
    # Constructs composable ConditionExpression for use in
    # DynamoDB API calls. Call to_s when sending to DynamoDB.
    #
    # Note:
    # where, and, or, and_not, or_not, where_not pass their arguments to
    # the Statement constructor. Read the docs there for placeholder syntax.
    #
    # Usage:
    # exp = Dynamo::Expressions::ConditionExpression.new
    #       .where('token_channel = :?', values: ['123'])
    #       .and('ts > :?', values: [1344])
    #
    # exp.or do |expression|
    #   expression
    #     .where('attribute_exists(#?)', names: ['count'])
    #     .and('attribute_exists(something)')
    # end
    #
    # Later...
    #
    # exp.and { |e| e.where('ts BETWEEN :? AND :?', values: [1, 2]) }
    #
    # The expression above would produce the following with `to_s`
    #
    # "token_channel = :VALUE_757d204b68e8e1c419288694ab908f55 AND
    #   ts > :VALUE_a50abba8132a77191791390c3eb19fe7 OR
    #   (attribute_exists(#NAME_d61a1061060c9e9691027c42d6766b90) AND attribute_exists(something)) AND 
    #   (ts BETWEEN :VALUE_c4ca4238a0b923820dcc509a6f75849b AND :VALUE_c81e728d9d4c2f636f067f89cc14862c)"
    class ConditionExpression
      attr_reader :attribute_names, :attribute_values

      def initialize(attribute_names: nil, attribute_values: nil, &block)
        @attribute_names = attribute_names || AttributeNames.new
        @attribute_values = attribute_values || AttributeValues.new
      end

      def statements
        @statements ||= []
      end

      def or(*args, &block)
        add_statement('OR', *args, &block)
        self
      end

      def or_not(*args, &block)
        add_statement(%w(OR NOT), *args, &block)
        self
      end

      def and(*args, &block)
        add_statement('AND', *args, &block)
        self
      end

      def and_not(*args, &block)
        add_statement(%w(AND NOT), *args, &block)
        self
      end

      alias_method :where, :and
      alias_method :where_not, :and_not

      def to_s(wrap: true)
        str = statements.map(&:to_s).join(' ')
        wrap ? "(#{str})" : str
      end

      private

      def add_statement(operator, exp = nil, values: [], names: [], &block)
        return self if exp.nil? && block.nil?

        statement =
          if block
            exp = self.class.new(attribute_names: attribute_names,
                                 attribute_values: attribute_values)
            block.call(exp)
          else
            Statement.new(exp, values: values, names: names)
          end

        if statements.present?
          operator = operator.join(' ') if operator.is_a?(Array)
        else
          operator = operator.is_a?(Array) ? operator.last : nil
        end

        statements << operator if operator.present?
        statements << statement

        values.each { |v| attribute_values.add(v) }
        names.each { |n| attribute_names.add(n) }
      end
    end
  end
end
