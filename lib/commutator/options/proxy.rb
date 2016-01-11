module Commutator
  module Options
    class Proxy
      attr_reader :proxied_history, :options

      def initialize(context, callback_name)
        @context = context
        @callback_name = callback_name
        @proxied_history = []

        @options = instantiate_options
      end

      class Operation
        attr_reader :method, :args, :block

        def initialize(method, args, block)
          @method = method
          @args = args
          @block = block
        end

        def apply(options, chainable_history = nil)
          options.send(method, *args, &block).tap do |result|
            # if result == self then that was a call to #with_context
            chainable_history << self if chainable_history && result == options
          end
        end
      end

      def method_missing(method_name, *args, &block)
        super unless options.respond_to?(method_name)

        operation = Operation.new(method_name, args, block)
        result = operation.apply(@options, @proxied_history)
        result != options ? result : self
      end

      def respond_to?(*args)
        super || options.respond_to?(*args)
      end

      def context(context)
        @context = context
        @options = rehydrate_options
        self
      end

      def options
        @options ||= rehydrate_options
      end

      def execute
        @context.send(callback_name, options)
      end

      def first
        # TODO: asc / desc only work on Query (not Scan)
        limit(1).asc.execute.items.first
      end

      def last
        # TODO: asc / desc only work on Query (not Scan)
        limit(1).desc.execute.items.first
      end

      def count
        response = @context.client.send(callback_name, options.dup.select("COUNT"))
        response.inject(0) { |sum, page| sum + page.count }
      end

      private

      def instantiate_options
        @context.run_before_hooks(
          @callback_name,
          @context.options_class(@callback_name).new._proxy(self)
        )
      end

      def rehydrate_options
        instantiate_options.tap do |options|
          proxied_history.each { |operation| operation.apply(options) }
        end
      end

      attr_reader :callback_name
    end
  end
end
