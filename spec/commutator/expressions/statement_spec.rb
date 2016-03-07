require 'spec_helper'

RSpec.describe Commutator::Expressions::Statement do
  let(:placeholder) { Commutator::Util::Placeholders }

  describe '#to_s' do
    it 'replaces placeholders with names and values' do
      statement = described_class.new(
        '#? = :? OR #? = :? OR attribute_exists(some_attr_name)',
        names: %w(count token),
        values: [100, '123']
      )

      expected = "#{placeholder.name('count')} = #{placeholder.value(100)} OR " \
                 "#{placeholder.name('token')} = #{placeholder.value('123')} OR " \
                 'attribute_exists(some_attr_name)'

      expect(statement.to_s).to eq(expected)
    end
  end
end
