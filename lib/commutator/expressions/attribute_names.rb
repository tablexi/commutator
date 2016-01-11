module Commutator
  module Expressions
    class AttributeNames
      def initialize
        @names = {}
      end

      def add(name)
        name = name.to_s
        placeholder = Util::Placeholders.name(name)

        names[placeholder] = name unless placeholder == name
      end

      def to_h
        Marshal.load(Marshal.dump(names))
      end

      private

      attr_reader :names
    end
  end
end
