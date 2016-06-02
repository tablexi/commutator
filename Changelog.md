### Development
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.2.3...master)

### 0.2.3 / 2016-06-02
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.2.2...v0.2.3)

Bug fixes:

* Return meaningful string from Commutator::Proxy::Options#inspect rather
  than raising an error. Fixes #7 (Bradley Schaefer)
* Support Ruby 2.3+ - a compatibility issue was exposed by implementing
  TravisCI integration. (Bradley Schaefer)

### 0.2.2 / 2016-03-07
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.2.1...v0.2.2)

Bug fixes:

* Accept any arguments for `respond_to?` in `Commutator::Model` (Bradley Schaefer) 

### 0.2.1 / 2016-03-07
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.2.0...v0.2.1)

Bug fixes:

* Fixed incorrect method name in `inherited` Scope-copying code (Bradley Schaefer)

### 0.2.0 / 2016-03-07
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.1.1...v0.2.0)

Features:

* Can configure table name at the instance level. (Bradley Schaefer)
* Port over a ton of Ben Kimpel's tests (Bradley Schaefer)

Bug fixes:

* Resolve a concurrency bug involving lazy instantiation (Bradley Schaefer)

### 0.1.1 / 2016-01-15
[Full Changelog](http://github.com/tablexi/commutator/compare/v0.1.0...v0.1.1)

Features:

* Add `Commutator::Collection::CachedLookup` (Bradley Schaefer)

Bug fixes:

* Change lazy-loading of Commutator::Model.client to be eager-loaded
  to facilitate the ability to override the client. (Bradley Schaefer)

### 0.1.0 / 2016-01-11

Initial release!

* No tests, not guaranteed to be fully functional (sorry!)
* Operations include Query, Scan, PutItem, UpdateItem, DeleteItem, GetItem
* Support for AR-like 'scopes' via defining a `Scopes` module within a model
* `modify_collection_items_with proc, factory: [boolean](default: false)` gives
  ability to decorate items in a collection (e.g. for caching relation lookups)…
  it's a tricky feature to explain :/
* collection supports pagination or 'normal' iteration via `#each_page` and `#each_item`
