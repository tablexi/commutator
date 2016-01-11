module Commutator
  module Model
    # Some basic configuration related to a Dynamo table
    module TableConfiguration
      extend ActiveSupport::Concern

      delegate :primary_key_hash_name,
               :primary_key_range_name,
               to: 'self.class'

      def primary_key_hash
        send(primary_key_hash_name)
      end

      def primary_key_range
        send(primary_key_range_name) if primary_key_range_name.present?
      end

      def table_name
        self.class.table_name
      end

      # :nodoc:
      module ClassMethods
        attr_reader :primary_key_hash_name,
                    :primary_key_range_name

        def primary_key(options = {})
          @primary_key_hash_name = options[:hash]
          @primary_key_range_name = options[:range]
        end

        def table_name(table_name = nil)
          return @table_name unless table_name.present?

          @table_name = table_name
        end
      end
    end
  end
end
