require 'spec_helper'

RSpec.describe Commutator::Model::Attributes do
  subject(:instance) { test_class.new }

  let(:test_class) { Class.new { include Commutator::Model::Attributes } }

  describe '#assign_attributes' do
    before do
      test_class.class_eval do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'updates the attribute values' do
      expect(instance.attr_1).to be_nil
      expect(instance.attr_2).to be_nil

      instance.assign_attributes(attr_1: 'new value 1', attr_2: 'new value 2')

      expect(instance.attr_1).to eq('new value 1')
      expect(instance.attr_2).to eq('new value 2')
    end

    it 'ignores unknown attributes' do
      expect { instance.assign_attributes(not_there: 'oops') }
        .not_to raise_error
    end
  end

  describe '#attributes' do
    before do
      test_class.class_eval do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'returns the current attribute values' do
      new_values = { attr_1: 'val 1', attr_2: 'val 2' }

      instance.assign_attributes(new_values)

      expect(instance.attributes).to eq(new_values)
    end
  end

  describe '#attribute_names' do
    before do
      test_class.class_eval do
        attribute :attr_1
        attribute :attr_2
      end
    end

    it 'returns a set of the attribute names' do
      expect(instance.attribute_names).to eq(Set.new([:attr_1, :attr_2]))
    end
  end

  describe '.attribute' do
    it 'registers an attribute name' do
      test_class.class_eval do
        attribute :attr_1
        attribute :attr_2
      end

      expect(test_class.attribute_names).to eq(Set.new([:attr_1, :attr_2]))
    end

    it 'accepts multiple attribute names per call' do
      test_class.class_eval do
        attribute :attr_1, :attr_2
      end

      expect(test_class.attribute_names).to eq(Set.new([:attr_1, :attr_2]))
    end

    it 'supports type conversion' do
      test_class.class_eval do
        attribute :attr_1, type: :array
        attribute :attr_2, type: :boolean, allow_nil: false
        attribute :attr_3, type: :float
        attribute :attr_4, type: :hash
        attribute :attr_5, type: :integer
        attribute :attr_6, type: :set
        attribute :attr_7, type: :string
      end

      instance.assign_attributes(
        attr_1: {},
        attr_2: nil,
        attr_3: '1.2',
        attr_4: [],
        attr_5: '1',
        attr_6: [],
        attr_7: 1
      )

      expected = {
        attr_1: [],
        attr_2: false,
        attr_3: 1.2,
        attr_4: {},
        attr_5: 1,
        attr_6: Set.new,
        attr_7: '1'
      }

      expect(instance.attributes).to eq(expected)
    end

    it 'generates accessor methods' do
      test_class.class_eval do
        attribute :attr_1
      end

      expect(instance).to respond_to(:attr_1)
      expect(instance).to respond_to(:attr_1=)
    end

    it 'does not generate reader/writer if accessor is false' do
      test_class.class_eval do
        attribute :attr_1, accessor: false
      end

      expect(instance).not_to respond_to(:attr_1)
      expect(instance).not_to respond_to(:attr_1=)
    end

    it 'does not generate reader if reader is false' do
      test_class.class_eval do
        attribute :attr_1, writer: false
      end

      expect(instance).to respond_to(:attr_1)
      expect(instance).not_to respond_to(:attr_1=)
    end

    it 'does not generate writer if writer is false' do
      test_class.class_eval do
        attribute :attr_1, reader: false
      end

      expect(instance).not_to respond_to(:attr_1)
      expect(instance).to respond_to(:attr_1=)
    end
  end

  describe '.attribute_names' do
    it 'returns a set of the attribute names' do
      test_class.class_eval do
        attribute :attr_1
        attribute :attr_2
      end

      expect(test_class.attribute_names).to eq(Set.new([:attr_1, :attr_2]))
    end
  end
end
