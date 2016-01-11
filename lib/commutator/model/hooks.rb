module Commutator
  module Model
    module Hooks
      extend ActiveSupport::Concern

      def run_before_hooks(operation, options)
        self.class.before_hooks[operation].each do |method_name|
          send(method_name, options)
        end

        options
      end

      module ClassMethods
        API_ITEM_OPERATIONS.each do |operation|
          define_method "before_#{operation}" do |*args|
            add_before_hook(operation, *args)
          end
        end

        def add_before_hook(operation, *method_names)
          method_names.each do |method_name|
            before_hooks[operation] << method_name
          end
        end

        def before_hooks
          @before_hooks ||= Hash.new { |h, k| h[k] = [] }
        end

        def run_before_hooks(operation, options)
          before_hooks[operation].each do |method_name|
            send(method_name, options)
          end

          options
        end
      end
    end
  end
end
