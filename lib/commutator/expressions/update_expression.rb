module Commutator
  module Expressions
    # See: http://goo.gl/qiHKO3
    #
    # Constructs composable UpdateExpression for use in
    # DynamoDB API calls. Call to_s when sending to DynamoDB.
    #
    # Note:
    # SET, REMOVE, ADD, and DELETE pass their arguments to
    # the Statement constructor. Read the docs there for placeholder syntax.
    #
    # Usage:
    # exp = Commutator::Expressions::UpdateExpression.new
    #       .set('username = :?', values: ['user1'])
    #       .set('email = :?', values: ['a@b.c'])
    #       .add('login_count :?', values: [1])
    #       .remove('some_attribute')
    #       .delete('some_set :?', values: [10])
    #
    # The expression above would produce the following with `to_s`
    #
    # "SET username = :VALUE_91120aaf65529fbdc83e66ea160f17bc,
    #   email = :VALUE_73a839aafcf0207ab931d9edd6369a9a
    #   ADD login_count :VALUE_c4ca4238a0b923820dcc509a6f75849b
    #   REMOVE some_attribute
    #   DELETE some_set :VALUE_d3d9446802a44259755d38e6d163e820"
    class UpdateExpression
      attr_reader :attribute_names, :attribute_values

      def initialize(attribute_names: nil, attribute_values: nil, &block)
        @attribute_names = attribute_names || AttributeNames.new
        @attribute_values = attribute_values || AttributeValues.new
      end

      def sections
        @sections ||= Hash.new { |h, v| h[v] = [] }
      end

      %w(set remove add delete).each do |method_name|
        define_method method_name do |*args|
          add_to_section(method_name.downcase.to_sym, *args)
        end
      end

      def add_to_section(name, exp, names: [], values: [])
        names.each { |n| attribute_names.add(n) }
        values.each { |v| attribute_values.add(v) }

        sections[name] << Statement.new(exp, names: names, values: values)

        self
      end

      def to_s
        sections
          .map { |name, actions| "#{name.upcase} #{actions.join(', ')}" }
          .join(' ')
      end
    end
  end
end
