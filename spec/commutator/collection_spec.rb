require 'spec_helper'
require 'delegate'

RSpec.describe Commutator::Collection, :dynamo do
  class Whatever
    include Commutator::Model

    primary_key hash: :whatever
    table_name :whatever
    self.client = Class.new { include DynamoHelpers }.new.dynamo_client

    attribute :whatever
  end

  let(:db) { dynamo_client }
  let(:collection) { described_class.new(response, Whatever) }
  let(:table_name) { Whatever.table_name }

  let(:paginated_response) do
    db.scan(limit: 1,
            table_name: table_name,
            filter_expression: 'whatever = :val1 OR whatever = :val2',
            expression_attribute_values: {
              ':val1' => 'hello',
              ':val2' => 'goodbye'
            })
  end

  let(:response) { paginated_response }

  before do
    create_table(table_name, hash_key: { name: 'whatever', type: 'S' })

    Whatever.create(whatever: 'hello')
    Whatever.create(whatever: 'goodbye')
  end

  after do
    delete_table(Whatever.table_name)
  end

  describe '#items' do
    it 'returns an array of instances of the specified class (paginated)' do
      expect(collection.items).to eq([Whatever.new(whatever: 'hello')])
    end
  end

  describe '#next_page' do
    it 'returns another collection' do
      expect(collection.next_page).to be_a(described_class)
    end
  end

  describe '#each_page' do
    it 'returns a collection instance for each page' do
      expect { |block| collection.each_page(&block) }
        .to yield_successive_args(an_instance_of(described_class),
                                  an_instance_of(described_class))
    end

    it 'returns an enumerator without a block argument' do
      enum = collection.each_page
      expect(enum.next).to be_an_instance_of(Commutator::Collection)
      expect(enum.next).not_to eq collection
    end
  end

  describe '#each_item' do
    it 'returns an instance of the specified class for each item' do
      expected = [
        Whatever.new(whatever: 'hello'),
        Whatever.new(whatever: 'goodbye')
      ]

      expect { |block| collection.each_item(&block) }
        .to yield_successive_args(*expected)
    end

    it 'returns an enumerator without a block argument' do
      enum = collection.each_item
      expect(enum.next).to eq Whatever.new(whatever: 'hello')
      expect(enum.next).to eq Whatever.new(whatever: 'goodbye')
    end
  end

  describe '#count' do
    it 'returns the count for the current page' do
      expect(collection.count).to eq(1)
    end
  end

  describe '#scanned_count' do
    it 'returns the scanned_count for the current page' do
      expect(collection.scanned_count).to eq(1)
    end
  end

  describe '#last_evaluated_key' do
    it 'returns the last_evaluated_key for the current page' do
      expect(collection.last_evaluated_key).to eq('whatever' => 'hello')
    end
  end

  describe '#next_page?' do
    it 'returns true if there is a next page' do
      expect(collection.next_page?).to eq(true)
    end
  end

  describe "#modify_with(modifier)" do
    let(:modified) {
      collection.modify_with(Proc.new do |item|
        item.define_singleton_method(:extra_method) { true }
      end)
    }

    it "modifies items returned by #each_item" do
      item = modified.each_item.next
      expect(item).to respond_to(:extra_method)
      expect(item).to respond_to(:whatever)
    end

    it "modifies items returned by pages returned by #each_page" do
      page = modified.each_page.next
      item = page.each_item.next
      expect(item).to respond_to(:extra_method)
      expect(item).to respond_to(:whatever)
    end

    it "accumulates modifiers and applies them all in order" do
      multi_modified = modified.modify_with(Proc.new do |item|
        item.define_singleton_method(:extra_method2) { true }
        item.define_singleton_method(:extra_method3) { "TRUE" }
      end)
      multi_modified = multi_modified.modify_with(Proc.new do |item|
        item.define_singleton_method(:extra_method3) { true }
      end)

      item = multi_modified.each_item.next

      expect(item).to respond_to(:whatever)
      expect(item).to respond_to(:extra_method)
      expect(item).to respond_to(:extra_method2)
      expect(item).to respond_to(:extra_method3)

      expect(item.extra_method3).to eq true
    end
  end
end
