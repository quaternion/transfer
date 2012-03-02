require 'sequel'

Sequel.extension :migration

DESTINATION_DB = Sequel.sqlite

class SequelUserMigration < Sequel::Migration
  def up
    create_table! :sequel_users do
      primary_key :id
      String :first_name
      String :last_name
      String :full_name
      String :before_save_value
      String :protected_value
    end
  end
  def down
    drop_table :sequel_users
  end
end


SequelUserMigration.apply DESTINATION_DB, :up


class SequelUser < Sequel::Model
  attr_accessor :dynamic_value
  set_restricted_columns :protected_value
end


class SequelUserWithFalseValidation < Sequel::Model(:sequel_users)
  attr_accessor :dynamic_value
  set_restricted_columns :protected_value

  def validate
    super
    errors.add(:fake, 'fake error')
  end
end


SequelUser.db = DESTINATION_DB
SequelUserWithFalseValidation.db = DESTINATION_DB
