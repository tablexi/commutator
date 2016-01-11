module Commutator
  module Model
    # This module provides methods related to registering attributes
    # and generating attr_accessors, ultimately for the purpose of
    # enabling Dynamo::Model to know which attributes to send to the db.
    module Attributes
      extend ActiveSupport::Concern

      def assign_attributes(attrs = {})
        attrs.slice(*attribute_names).each do |attr_name, value|
          send("#{attr_name}=", value)
        end
      end

      def attributes
        attribute_names.each_with_object({}) do |attr_name, hash|
          hash[attr_name] = send(attr_name)
        end
      end

      def attribute_names
        self.class.attribute_names
      end

      private

      def convert_type(value, options)
        return if options.fetch(:allow_nil, true) && value.nil?

        case options[:type]
        when :array then value.to_a
        when :boolean then !!value
        when :float then value.to_f
        when :hash then value.to_h
        when :integer then value.to_i
        when :set then Set.new(value)
        when :string then value.to_s
        else value
        end
      end

      # :nodoc:
      module ClassMethods
        def attribute(*attr_names)
          options = attr_names.extract_options!

          attr_names.each do |attr_name|
            attribute_names << attr_name

            # Skip reader and writer methods entirely
            next if options[:accessor] == false

            define_writer(attr_name, options) unless options[:writer] == false
            attr_reader attr_name unless options[:reader] == false
          end
        end

        def attribute_names
          @attribute_names ||= Set.new
        end

        private

        def define_writer(attr_name, options)
          define_method "#{attr_name}=" do |value|
            instance_variable_set("@#{attr_name}", convert_type(value, options))
          end
        end
      end
    end
  end
end
