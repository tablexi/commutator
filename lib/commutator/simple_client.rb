module Commutator
  # Provides an instance of `Aws::DynamoDB::Client` with conversions for passing
  # Commutator objects to API operations.
  #
  # `:client => ` may be provided as an `Aws::DynamoDB::Client` instance
  # otherwise this instantiates a `Aws::DynamoDB::Client` with the provided options
  class SimpleClient < SimpleDelegator
    def initialize(client: nil, **options)
      return super(client) if client

      defaults = {
        region: "us-east-1",
        endpoint: "https://dynamodb.us-east-1.amazonaws.com",
      }
      options = defaults.merge options

      super Aws::DynamoDB::Client.new(options)
    end

    API_OPERATIONS.each do |operation|
      define_method(operation) do |kwargs|
        kwargs = kwargs.to_hash if kwargs.respond_to? :to_hash
        __getobj__.send(operation, kwargs)
      end
    end
  end
end
