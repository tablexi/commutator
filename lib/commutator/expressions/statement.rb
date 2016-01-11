module Commutator
  module Expressions
    # Statement simply takes a string and substitutes '#?' for name placeholders
    # and ':?' for value placeholders.
    #
    # Example:
    # Statement.new('#? BETWEEN :? AND :?', names: ['ts'], values: [100, 200])
    #
    # produces...
    #
    # "ts BETWEEN :VALUE_f899139df5e1059396431415e770c6dd AND :VALUE_3644a684f98ea8fe223c713b77189a77"
    # (Note: ts was not replaced because it's not a reserved word)
    #
    # Another example:
    # Statement.new('attribute_exists(#?)', names: ['count']).to_s
    #
    # produces...
    #
    # "attribute_exists(#NAME_d61a1061060c9e9691027c42d6766b90)"
    class Statement
      attr_accessor :exp, :names, :values

      def initialize(exp, names: [], values: [])
        @exp = exp
        @names = names
        @values = values
      end

      def to_s
        exp
          .gsub('#?')
          .each_with_index { |_v, i| Util::Placeholders.name(names[i]) }
          .gsub(':?')
          .each_with_index { |_v, i| Util::Placeholders.value(values[i]) }
      end
    end
  end
end
