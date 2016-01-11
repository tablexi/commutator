module Commutator
  # Wraps a DynamoDB response from query or scan operations to provide
  # a collection of instances of the given class.
  #
  # NOTE: This can't use SimpleDelegator because `Seahorse::Client::Response` does
  #       not implement `#respond_to?` as needed.
  class Collection
    autoload :CachedLookup, "commutator/collection/cached_lookup"

    delegate :count,
             :scanned_count,
             :last_evaluated_key,
             :consumed_capacity,
             :next_page?,
             to: :response

    def initialize(response, klass, modifiers: [])
      @response = response
      @klass = klass
      @modifiers = modifiers.map(&:expand_proc_modifiers).freeze
    end

    def items
      return [] if response.items.nil?

      response.items.map do |item|
        item = klass.new(item)
        modify_item(item)
      end
    end

    # Caution! This advances a page pointer in the response and there's no
    # going back. It will affect how each_page and each_item behaves.
    # In most cases it's better to use one of the each methods.
    def next_page
      self.class.new(response.next_page, klass)
    end

    def each_page
      return enum_for(:each_page) unless block_given?

      response.each do |page|
        next unless page.items.present?
        page = self.class.new(page, klass, modifiers: @modifiers)
        yield(page)
      end
    end

    def each_item
      return enum_for(:each_item) unless block_given?

      each_page do |page|
        page.items.each { |item| yield(item) }
      end
    end

    def all_items
      each_item.each_with_object([]) { |item, arr| arr << item }
    end

    def modify_with(*modifiers, factory: false)
      modifier = ItemModifiers.new(modifiers, factory: factory)
      # preserves decorator ordering with minimal object creation
      new_modifiers = [modifier].unshift(*@modifiers)

      self.class.new(response, klass, modifiers: new_modifiers)
    end

    private

    def modify_item(item)
      @modifiers.each do |modifier|
        modifier.modify(item)
      end
      item
    end

    attr_reader :response, :klass
  end
end
