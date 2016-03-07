require 'spec_helper'

RSpec.describe Commutator::Model, :dynamo do
  let(:test_class) do
    client = dynamo_client
    Class.new do
      include Commutator::Model

      attribute :username, :whatever
      attribute :age, type: :integer

      primary_key hash: :username, range: :age

      validates :username, presence: true

      table_name 'test_table'
      self.client = client

      # Required for ActiveModel::Model, not relevant to the specs
      def self.name
        'TestClass'
      end
    end
  end

  subject(:model) { test_class.new(valid_args) }
  let(:invalid_model) { test_class.new(invalid_args) }

  let(:valid_args) { { username: 'user', age: 4_000 } }
  let(:invalid_args) { {} }

  let(:db) { dynamo_client }
  let(:table_name) { 'test_table' }

  before do
    create_table(table_name,
                 hash_key: { name: 'username', type: 'S' },
                 range_key: { name: 'age', type: 'N' })
  end

  after do
    delete_table(table_name)
  end

  describe '.get_item_options' do
    it 'returns the matching instance' do
      model.put_item_options.execute

      actual = test_class.get_item_options
               .key('username' => model.username, 'age' => model.age)
               .execute

      expect(actual).to eq(model)
    end

    it 'returns nil if not found' do
      actual = test_class.get_item_options
               .key('username' => 'nope', 'age' => 0)
               .execute

      expect(actual).to be_nil
    end
  end

  describe '.query_options' do
    it 'returns a Commutator::Collection' do
      actual = test_class.query_options
               .with_key_condition_expression { |exp|
                 exp.and('username = :?', values: ['x'])
                 exp.and('age = :?', values: [100])
               }
               .execute

      expect(actual).to be_a(Commutator::Collection)
    end

    it 'includes the Scopes module' do
      test_class.class_eval do
        const_set("Scopes", Module.new {
          def user_age(username, age)
            with_key_condition_expression do |exp|
              exp.and('username = :?', values: [username])
              exp.and('age = :?', values: [age])
            end
          end
        })
      end

      actual = test_class.query_options.user_age("x", 100).execute
      expect(actual).to be_a(Commutator::Collection)
    end
  end

  describe '.scan_options' do
    it 'returns a Commutator::Collection' do
      actual = test_class.scan_options
               .with_filter_expression { |exp|
                 exp.and('username = :?', values: ['y'])
                 exp.and('age = :?', values: [40_000])
               }
               .execute

      expect(actual).to be_a(Commutator::Collection)
    end
  end

  describe '#put_item_options' do
    it 'creates a new item' do
      expected = {
        'username' => 'user',
        'age' => BigDecimal.new(4_000.to_s),
        'whatever' => nil
      }

      expect { model.put_item_options.execute }
        .to change { db.scan(table_name: table_name).count }.from(0).to(1)

      expect(db.scan(table_name: table_name).items)
        .to include(expected)
    end

    it 'replaces an existing item' do
      expected = {
        'username' => 'user',
        'age' => BigDecimal.new(4_000.to_s),
        'whatever' => 'YES'
      }

      model.put_item_options.execute
      model.assign_attributes(whatever: 'YES')

      expect { model.put_item_options.execute }
        .not_to change { db.scan(table_name: table_name).count }

      expect(db.scan(table_name: table_name).items)
        .to include(expected)
    end

    it 'returns true if successful' do
      expect(model.put_item_options.execute).to eq(true)
    end

    it 'returns false if unsuccessful' do
      expect(invalid_model.put_item_options.execute).to eq(false)
    end

    it 'does not call Dynamo client if validation fails' do
      client_spy = spy('Commutator::SimpleClient')

      test_class.client = client_spy

      model = test_class.new(invalid_args)
      model.put_item_options.execute

      expect(client_spy).not_to have_received(:put_item)
    end

    it 'runs validations' do
      invalid_model.put_item_options.execute

      expect(invalid_model.errors).to be_present
    end
  end

  context 'with a DynamoDB ServiceError' do
    let(:client) { double }
    let(:error) { Aws::DynamoDB::Errors::ServiceError.new(nil, 'Error msg') }
    let(:model) { test_class.new(valid_args) }

    before do
      test_class.client = client
    end

    describe '#delete_item_options' do
      before { allow(client).to receive(:delete_item).and_raise(error) }

      it 'returns false' do
        expect(model.delete_item_options.execute).to eq(false)
      end

      it 'adds the exception message to the errors' do
        model.delete_item_options.execute
        expect(model.errors[:base]).to include('Error msg')
      end
    end

    describe '#put_item_options' do
      before { allow(client).to receive(:put_item).and_raise(error) }

      it 'returns false' do
        expect(model.put_item_options.execute).to eq(false)
      end

      it 'adds the exception message to the errors' do
        model.put_item_options.execute
        expect(model.errors[:base]).to include('Error msg')
      end
    end
  end

  describe '#delete_item_options' do
    it 'deletes the item' do
      model.put_item_options.execute

      expect { model.delete_item_options.execute }
        .to change { db.scan(table_name: table_name).count }.from(1).to(0)
    end

    it 'freezes the item' do
      model.put_item_options.execute
      model.delete_item_options.execute

      expect(model).to be_frozen
    end
  end

  describe '#deleted?' do
    it 'returns true if deleted' do
      model.put_item_options.execute
      model.delete_item_options.execute

      expect(model).to be_deleted
    end

    it 'returns false if not deleted' do
      model.put_item_options.execute

      expect(model).not_to be_deleted
    end
  end

  describe '.create' do
    it 'creates a new item' do
      expect { test_class.create(valid_args) }
        .to change { db.scan(table_name: table_name).count }.from(0).to(1)
    end
  end

  describe ".modify_collection_with" do
    let(:modifier_proc) do
      Proc.new do |item|
        item.define_singleton_method(:modified?) { true }
      end
    end

    before do
      # populate an item
      model.put_item_options.execute
      test_class.class_eval { def modified?; false; end }
    end

    it "modifies returned items with a Proc" do
      modifier = modifier_proc # closure dictates a local variable
      test_class.class_eval { modify_collection_items_with modifier }

      item = test_class.scan.each_item.first

      expect(item).to be_modified
    end

    it "modifies returned items with a proc's return value when factory: true" do
      number = 0
      modifier = Proc.new do
        number += 1
        val = number
        Proc.new do |item|
          item.define_singleton_method(:modified?) { val }
        end
      end
      test_class.class_eval { modify_collection_items_with modifier, factory: true }

      item = test_class.scan.each_item.first

      expect(item).to be_modified
      expect(item.modified?).to eq 1
      expect(test_class.scan.each_item.first.modified?).to eq 2
    end
  end
end
