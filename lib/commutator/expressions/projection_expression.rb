module Commutator
  module Expressions
    # See: http://goo.gl/bOKUjK
    #
    # Constructs composable ProjectionExpression for use in
    # DynamoDB API calls. Call to_s when sending to DynamoDB.
    #
    # Note:
    # path passes its arguments to the Statement constructor. Read the
    # docs there for placeholder syntax.
    #
    # Usage:
    # exp = Dynamo::Expressions::ProjectionExpression.new
    #       .path('token_channel')
    #       .path('ts.items[2]')
    #       .path('#?', names: ['count'])
    #       .path('#?.hey', names: ['size'])
    #
    # Later...
    #
    # exp.path('another_one')
    #
    # The expression above would produce the following with `to_s`
    #
    # "token_channel, ts.items[2], #NAME_d61a1061060c9e9691027c42d6766b90, 
    #   #NAME_1eb3b08a347050ee467a2e24e6c15349.hey, another_one"
    class ProjectionExpression
      attr_reader :attribute_names

      def initialize(attribute_names: nil, &block)
        @attribute_names = attribute_names || AttributeNames.new
      end

      def statements
        @statements ||= []
      end

      def path(p, names: [])
        names.each { |n| attribute_names.add(n) }
        statements << Statement.new(p, names: names)

        self
      end

      def to_s
        statements.join(', ')
      end
    end
  end
end
