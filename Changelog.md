### Development
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.1.0...master)

* Add `Commutator::Collection::CachedLookup` (Bradley Schaefer)

### 0.1.0 / 2016-01-11

Initial release!

* No tests, not guaranteed to be fully functional (sorry!)
* Operations include Query, Scan, PutItem, UpdateItem, DeleteItem, GetItem
* Support for AR-like 'scopes' via defining a `Scopes` module within a model
* `modify_collection_items_with proc, factory: [boolean](default: false)` gives
  ability to decorate items in a collection (e.g. for caching relation lookups)…
  it's a tricky feature to explain :/
* collection supports pagination or 'normal' iteration via `#each_page` and `#each_item`
