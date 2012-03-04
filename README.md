## Transfer Gem
Transfer data from source database to ActiveRecord, SequelModel or Mongoid models.

### Installation
Include Transfer in Gemfile:

```ruby
gem 'transfer'
```

You can run bundle from command line:

```console
bundle install
```


### Compatibility
Source database: all, supported by [Sequel](http://sequel.rubyforge.org/documentation.html).

Destination: ActiveRecord, SequelModel, Mongoid.


## Configure
Set connection options of source database and global parameters:

```ruby
Transfer.configure do |c|
  c.host = "localhost"
  c.adapter = "postgres"
  c.database = "source_database"
  c.user = "username"
  c.password = "password"
end
```

Available options:

* `validate` on/off model validations. Values: `true` or `false`, default is `false`.
* `failure_strategy` sets strategy if save of model is not successfully. Values: `:ignore` or `:rollback`, defult is `:ignore`.
* `before` [global callback](#global_callbacks).
* `success` [global callback](#global_callbacks).
* `failure` [global callback](#global_callbacks).
* `after` [global callback](#global_callbacks).
* another options interpreted as [Sequel database connection options](http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html).


## Usage
Direct transfer from source table `:users` to `User` model. All columns, including protected, existing in source table and destination model, will transferred:

```ruby
transfer :users => User
```

Filling the field `country` a constant value:

```ruby
transfer :users => User do
  country "England"
end
```
Transfer `:name` column from source table `:users` into `first_name` of `User` model:

```ruby
transfer :users => User do
  first_name :name
end
```
To produce, dynamic value (e.g. `dist_name` field), you can pass a block and access the row of source table:

```ruby
transfer :users => User do
  dist_name {|row| "Mr. #{row[:first_name]}"}
end
```

### Global callbacks <a name="global_callbacks"/>
This callbacks called for each `transfer`.

```ruby
Transfer.configure do |c|
  c.before do |klass, dataset|
    #...
  end
  c.success do |model, row|
    #...
  end
  c.failure do |model, row, exception|
    #...
  end
  c.after do |klass, dataset|
    #...
  end
end
```
Available global callbacks:

* `before` called before an transfer started. Parameters: `klass`, `dataset`.
* `success` called if save model is successfully. Parameters: `model`, `row`.
* `failure` called if save model is not successfully. Parameters: `row`, `exception`.
* `after` called after an transfer finished. Parameters: `klass`, `dataset`.

Description of parameters:

* `dataset` source table dataset, instance of [Sequel::Dataset](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html).
* `klass` is destination class.
* `model` builded model, instance of `klass`.
* `row` of source table. Type: `Hash`.
* `exception` if save of model is not successfull.


### Local transfer callbacks
You can specify callbacks in your `transfer` that are separate from the model callbacks. This callbacks called in model context, therefore `self` keyword points to model.

```ruby
transfer :users => User do
  before_save do |row|
    self.messages << Message.build(:title => "Transfer", :description => "Welcome to new site, #{row[:fname]}!")
  end
end
```
Available callbacks:

* `before_save` called before save model. Paramaters: `row`.
* `after_save` called after successfully save model. Parameters: `row`.

where `row` is row of source table, type: `Hash`.


### Filter columns
`only` filter passes source columns, specified in parameters.

```ruby
transfer :users => User do
  only :name
end
```
`except` filter passes all source columns, except for those that are specified in the parameters:

```ruby
transfer :users => User do
  except :name
end
```


### Replace global options
Global options can be replaced, if it passed to `transfer`.

```ruby
transfer :users => User, :validate => false, :failure_strategy => :rollback
```
Available options for replace:

* `validate`
* `failure_strategy`


### Logging
If you also want see progress of transfer in console, use e.g. [progressbar gem](https://github.com/peleteiro/progressbar) with global callbacks.

```ruby
require 'progressbar'

Transfer.configure do |c|
  c.before {|klass, dataset| @pbar = ProgressBar.new(klass.to_s, dataset.count) }
  c.success { @pbar.inc }
  c.after { @pbar.halt }
end

transfer :users => User
```
