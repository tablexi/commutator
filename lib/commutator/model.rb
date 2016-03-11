require "commutator/model/attributes"
require "commutator/model/table_configuration"
require "commutator/model/hooks"

module Commutator
  # Basic CRUD wrapper for items in a dynamodb table.
  #
  # This module is focused on collections of homogenous items within a
  # single table.
  #
  # TODO: support multiple tables
  #
  # class Person
  #   include Commutator::Model
  #
  #   attribute :first_name,
  #             :last_name,
  #             :email
  #
  #   attribute :age, type: :integer
  #   attribute :favorite_color, writer: false
  #
  #
  #   primary_key hash: :email, range: :age
  #
  #   def favorite_color=(color)
  #     @color = color.downcase
  #   end
  # end
  module Model
    extend ActiveSupport::Concern

    include ActiveModel::Model
    include Commutator::Model::Attributes
    include Commutator::Model::TableConfiguration
    include Commutator::Model::Hooks

    # These build up some basic Dynamo request options related to a particular
    # api action so that we don't have to specify them every time. They don't
    # override any values if they are present.
    included do
      before_put_item :configure_default_put_item
      before_update_item :configure_default_update_item
      before_delete_item :configure_default_delete_item

      before_query :configure_default_query
      before_scan :configure_default_scan
      before_get_item :configure_default_get_item

      class_attribute :collection_item_modifiers, instance_accessor: false
      class_attribute :client
      self.client = ::Commutator::SimpleClient.new

      class_attribute :scoped_options, instance_accessor: false
      self.scoped_options = options_cache_class
    end

    delegate :options_class, to: 'self.class'

    def initialize(attrs = {})
      assign_attributes(attrs.symbolize_keys)
    end

    def put_item_options
      self.class.build_options_proxy(:put_item, self)
    end

    def update_item_options
      self.class.build_options_proxy(:update_item, self)
    end

    def delete_item_options
      self.class.build_options_proxy(:delete_item, self)
    end

    def put_item(options = nil)
      dynamo_request(:put_item, options) unless invalid?
      errors.empty?
    end

    def update_item(options = nil)
      dynamo_request(:update_item, options) unless invalid?
      errors.empty?
    end

    def delete_item(options = nil)
      dynamo_request(:delete_item, options)
      return false if errors.present?

      @deleted = true
      freeze
    end

    def deleted?
      @deleted == true
    end

    def ==(other)
      self.class == other.class &&
        primary_key_hash == other.primary_key_hash &&
        primary_key_range == other.primary_key_range &&
        attributes == other.attributes
    end

    private

    def configure_default_put_item(options)
      options
        .table_name(table_name)
        .item(attributes.stringify_keys)
    end

    def configure_default_update_item(options)
      options.table_name(table_name)
    end

    def configure_default_delete_item(options)
      options
        .table_name(table_name)
        .with_key { |key| key[primary_key_hash_name] = primary_key_hash }

      return unless primary_key_range.present?

      options.with_key { |key| key[primary_key_range_name] = primary_key_range }
    end

    def dynamo_request(operation, options)
      options ||= self.class.options_class(operation).new
      run_before_hooks(operation, options)
      client.send(operation, options)
    rescue Aws::DynamoDB::Errors::ValidationException,
           Aws::DynamoDB::Errors::ServiceError => e
      errors.add(:base, e.message)
    end

    # :nodoc:
    module ClassMethods
      def inherited(subclass)
        subclass.attribute_names.merge(attribute_names)
        before_hooks.each { |k, v| subclass.before_hooks[k] = v.dup }

        subclass.table_name(table_name)
        subclass.primary_key(hash: primary_key_hash_name,
                             range: primary_key_range_name)
        subclass.scoped_options = options_cache_class

        scopes = const_defined?("Scopes", false) ? const_get("Scopes") : nil
        subclass.const_set("Scopes", Module.new { include scopes }) if scopes
      end

      def create(attrs)
        new(attrs).tap { |dp| dp.put_item_options.execute }
      end

      def modify_collection_items_with(*modifiers, factory: false)
        self.collection_item_modifiers = [
          ItemModifiers.new(modifiers, factory: factory)
        ].unshift(*collection_item_modifiers)
      end

      def get_item_options
        build_options_proxy(:get_item)
      end

      def query_options
        build_options_proxy(:query)
      end

      def scan_options
        build_options_proxy(:scan)
      end

      def get_item(options = build_options_proxy(:get_item))
        item = client.get_item(options).item
        new(item) unless item.nil?
      end

      def query(options = build_options_proxy(:query))
        collection_for(:query, options)
      end

      def scan(options = build_options_proxy(:scan))
        collection_for(:scan, options)
      end

      def build_options_proxy(operation, context = self)
        Options::Proxy.new(context, operation)
      end

      def options_class(operation)
        scoped_options[operation]
      end

      def method_missing(method, *args)
        super unless respond_to?(method)
        query_options.send(method, *args)
      end

      def respond_to?(method, *args)
        super || (const_defined?(:Scopes, false) && const_get(:Scopes).method_defined?(method))
      end

      private

      def options_cache_class
        Concurrent::Map.new do |h, k|
          scopes = self.const_defined?("Scopes", false) ? self.const_get("Scopes") : nil
          h.compute_if_absent(k) do
            const_name = k.to_s.camelize
            enhance_options(const_name, scopes)
          end
        end
      end

      def enhance_options(const_name, scopes = nil)
        Class.new(Options.const_get(const_name, false)) do
          include ::Commutator::Util::Fluent
          include scopes if scopes && %w[Query Scan].include?(const_name)

          fluent_accessor :_proxy
          delegate :context, to: :_proxy

          def inspect
            "#{const_name}Proxy (#{(public_methods.sort - Object.methods).join(", ")})"
          end
        end
      end

      def collection_for(operation, options)
        Collection.new(
          client.send(operation, options),
          self,
          modifiers: Array(collection_item_modifiers)
        )
      end

      def configure_default_query(options)
        options.table_name(table_name)
      end

      def configure_default_scan(options)
        options.table_name(table_name)
      end

      def configure_default_get_item(options)
        options.table_name(table_name)
      end
    end
  end
end
