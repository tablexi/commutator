module DynamoHelpers
  def dynamo_client
    Commutator::SimpleClient.new(endpoint: "http://localhost:8000")
  end

  def delete_table(name)
    dynamo_client.delete_table(table_name: name)
  end

  def create_table(name, hash_key:, range_key: nil)
    options = {
      table_name: name,
      attribute_definitions: [
        { attribute_name: hash_key[:name], attribute_type: hash_key[:type] }
      ],
      key_schema: [{ attribute_name: hash_key[:name], key_type: 'HASH' }],
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }

    if range_key
      options[:attribute_definitions] << {
        attribute_name: range_key[:name], attribute_type: range_key[:type]
      }

      options[:key_schema] << {
        attribute_name: range_key[:name], key_type: 'RANGE'
      }
    end

    dynamo_client.create_table(options)
  end
end
