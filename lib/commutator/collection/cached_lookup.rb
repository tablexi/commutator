module Commutator
  class Collection
    # Implemention of a per-collection cache to avoid repeating expensive
    # lookups. E.g. if several items in the collection refer to the same User
    # object, the following pattern would ensure the User is only looked up
    # once:
    #
    #     # (inside your model)
    #     CachedUserLookup = Proc.new do
    #       Commutator::Collection::CachedLookup.new(:user, :user_id) do |user_id|
    #         User.find(user_id)
    #       end
    #     end
    #
    #     modify_collection_items_with CachedUserLookup, factory: true
    #
    # Note: The cache itself is not accessible since it's hidden by the closure
    #       scope. Additionally, this returns the same instance of the object for
    #       every matching lookup - so be mindful when modifying that object.
    module CachedLookup
      def self.new(attr_name, item_key, &block)
        cache = Hash.new do |h, k|
          h[k] = block.call(k)
        end

        Proc.new do |item|
          item.define_singleton_method(attr_name) do
            cache[item.send(item_key)]
          end
        end
      end
    end
  end
end
