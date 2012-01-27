require 'sequel'

Sequel.extension :migration

SOURCE_DB = Sequel.sqlite

class SourceUserMigration < Sequel::Migration
  def up
    create_table! :source_users, :force => true do
      primary_key :id
      String :fname
      String :lname
    end
  end
  def down
    drop_table :source_users
  end
end


class SourceUser < Sequel::Model
end


SourceUserMigration.apply SOURCE_DB, :up
SourceUser.db = SOURCE_DB
