require 'spec_helper'

RSpec.describe Commutator::Model::TableConfiguration do
  subject(:instance) { test_class.new }

  let(:test_class) do
    Class.new do
      include Commutator::Model::TableConfiguration

      table_name 'test_table'

      primary_key hash: :username, range: :age

      def username
        'someuser'
      end

      def age
        100
      end
    end
  end

  describe ".table_name" do
    it "takes an argument in order to set the value" do
      expect(test_class.table_name).to eq 'test_table'
      test_class.table_name 'nonsense'
      expect(test_class.table_name).to eq 'nonsense'
    end
  end

  describe '#table_name' do
    it 'picks up the class level table_name value' do
      expect(instance.table_name).to eq(test_class.table_name)
    end
  end

  describe '#table_name=' do
    it 'sets the instance table name to a value that differs from the class-level value' do
      instance.table_name = 'new value'
      expect(instance.table_name).to eq 'new value'
      expect(instance.class.table_name).not_to eq(instance.table_name)
    end
  end

  describe '#primary_key_hash' do
    it 'returns the value of the primary key hash' do
      expect(instance.primary_key_hash).to eq('someuser')
    end
  end

  describe '#primary_key_range' do
    it 'returns the value of the primary key range' do
      expect(instance.primary_key_range).to eq(100)
    end
  end

  describe '#primary_key_hash_name' do
    it 'returns the name of the primary key hash' do
      expect(instance.primary_key_hash_name).to eq(:username)
    end
  end

  describe '#primary_key_range_name' do
    it 'returns the name of the primary key range' do
      expect(instance.primary_key_range_name).to eq(:age)
    end
  end

  describe '.table_name' do
    it 'set/gets the table name' do
      expect(test_class.table_name).to eq('test_table')
    end
  end

  describe '.primary_key_hash/range' do
    it 'sets the primary key hash and range names' do
      test_class.class_eval do
        primary_key hash: :hello, range: :yo
      end

      expect(test_class.primary_key_hash_name).to eq(:hello)
      expect(test_class.primary_key_range_name).to eq(:yo)
    end
  end

  describe '.primary_key_hash_name' do
    it 'returns the name of the primary key hash' do
      expect(test_class.primary_key_hash_name).to eq(:username)
    end
  end

  describe '.primary_key_range_name' do
    it 'returns the name of the primary key range' do
      expect(test_class.primary_key_range_name).to eq(:age)
    end
  end
end
