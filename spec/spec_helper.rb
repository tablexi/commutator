$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'commutator'
require 'dynamo_helpers'

RSpec.configure do |config|
  config.include DynamoHelpers, dynamo: true

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "spec/examples.txt"
end
