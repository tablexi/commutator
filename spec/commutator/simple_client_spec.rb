require 'spec_helper'

RSpec.describe Commutator::SimpleClient do
  it 'wraps an existing Aws DynamoDB client' do
    aws_client = Aws::DynamoDB::Client.new(
      region: 'us-east-1',
      access_key_id: '123',
      secret_access_key: 'abc',
      endpoint: 'http://localhost:4555'
    )

    expect(described_class.new(client: aws_client).__getobj__).to eq(aws_client)
  end

  it 'uses a preconfigured AWS DynamoDB client if none is provided' do
    config = described_class.new.config

    expect(config.region).to eq("us-east-1")
    expect(config.endpoint).to eq(URI("https://dynamodb.us-east-1.amazonaws.com"))
  end
end
