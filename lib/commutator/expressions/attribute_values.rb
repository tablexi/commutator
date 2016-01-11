module Commutator
  module Expressions
    class AttributeValues
      def initialize
        @values = {}
      end

      def add(value)
        values[Util::Placeholders.value(value)] = value
      end

      def to_h
        Marshal.load(Marshal.dump(values))
      end

      private

      attr_reader :values
    end
  end
end
