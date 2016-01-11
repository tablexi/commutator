require "aws-sdk"

require "active_model"

require "active_support"
require "active_support/core_ext"


module Commutator
  API_TABLE_OPERATIONS = [
    :create_table,
    :delete_table,
    :describe_table,
    :list_tables,
    :update_table
  ].freeze

  API_ITEM_OPERATIONS = [
    :batch_get_item,
    :batch_write_item,
    :delete_item,
    :get_item,
    :put_item,
    :update_item,
    :query,
    :scan
  ].freeze

  API_OPERATIONS = (
  API_TABLE_OPERATIONS +
    API_ITEM_OPERATIONS
  ).freeze

  autoload :Collection, "commutator/collection"
  autoload :ItemModifiers, "commutator/item_modifiers"
  autoload :Model, "commutator/model"
  autoload :SimpleClient, "commutator/simple_client"

  module Expressions
    autoload :AttributeNames, "commutator/expressions/attribute_names"
    autoload :AttributeValues, "commutator/expressions/attribute_values"
    autoload :ConditionExpression, "commutator/expressions/condition_expression"
    autoload :ProjectionExpression, "commutator/expressions/projection_expression"
    autoload :Statement, "commutator/expressions/statement"
    autoload :UpdateExpression, "commutator/expressions/update_expression"
  end

  module Options
    autoload :DeleteItem, "commutator/options/delete_item"
    autoload :GetItem, "commutator/options/get_item"
    autoload :Proxy, "commutator/options/proxy"
    autoload :PutItem, "commutator/options/put_item"
    autoload :Query, "commutator/options/query"
    autoload :Scan, "commutator/options/scan"
    autoload :UpdateItem, "commutator/options/update_item"
  end

  module Util
    autoload :Fluent, "commutator/util/fluent"
    autoload :Placeholders, "commutator/util/placeholders"
  end
end

require "commutator/version"
