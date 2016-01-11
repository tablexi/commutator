require "commutator/version"

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
end
