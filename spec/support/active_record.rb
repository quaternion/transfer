require 'active_record'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
ActiveRecord::Migration.verbose = false


class ActiveRecordUserMigration < ActiveRecord::Migration
  def self.up
    create_table :active_record_users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :before_save_value
    end
  end

  def self.down
    drop_table :active_record_users
  end
end

ActiveRecordUserMigration.up


class ActiveRecordUser < ActiveRecord::Base
  set_table_name "active_record_users"
  attr_accessor :dynamic_value
end

class ActiveRecordUserWithFalseValidation < ActiveRecord::Base
  set_table_name "active_record_users"
  attr_accessor :dynamic_value
  validate :fake

  def fake
    errors.add :fake, 'fake'
  end
end
