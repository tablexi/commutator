module Commutator
  module Util
    # This module provides fluent accessors and wrappers, which are probably
    # just terms I made up.
    #
    # Usage:
    # class Person
    #   include Commutator::Util::Fluent
    #
    #   fluent_accessor :first_name,
    #                   :last_name,
    #                   :pets
    #
    #   fluent_wrapper :pets
    #
    #   def initialize
    #     @pets = []
    #   end
    # end
    #
    # When called with an argument a fluent accessor will set a value
    # and return the instance again. This allows chaining.
    #
    # Ex:
    # person = Person.new.first_name('Seymour').last_name('Busses')
    # # => <#Person @first_name='Seymour', @last_name='Busses'>
    #
    # When called without an argument a fluent accessor will return the value
    # it has.
    # person = Person.new.first_name('Seymour')
    # person.first_name # => 'Seymour'
    #
    # A fluent wrapper allows you to manipulate "complex" objects and continue
    # to chain calls. Fluent wrappers start with a `with_` followed by the
    # attribute name. Fluent wrapper passes the value into a block.
    #
    # Ex:
    # person = Person.new
    #          .first_name('Hi')
    #          .with_pets { |pets| pets << 'mittens' }
    #
    module Fluent
      extend ActiveSupport::Concern

      module ClassMethods
        def fluent_wrapper(*attr_names)
          attr_names.each do |attr_name|
            define_method "with_#{attr_name}" do |&block|
              block.call(instance_variable_get("@#{attr_name}"))
              self
            end
          end
        end

        def fluent_accessor(*attr_names)
          attr_names.each do |attr_name|
            define_method attr_name do |*val|
              return instance_variable_get("@#{attr_name}") if val.empty?
              instance_variable_set("@#{attr_name}", val.first)
              self
            end
          end
        end
      end
    end
  end
end
