require 'rspec'
require 'rr'
require 'fabrication'
require 'transfer'
require 'support/source'
require 'support/sequel'
require 'support/active_record'
require 'support/mongoid'
require 'database_cleaner'

module TransfererHelper
  def save_failure entity
    if entity.kind_of?(Class)
      instance_of(entity).save! { raise "force exception!" }
      instance_of(entity).save  { raise "force exception!" }
    else
      stub(entity).save! { raise "force exception!" }
      stub(entity).save  { raise "force exception!" }
    end
  end
end

RSpec.configure do |c|
  c.mock_with :rr
  c.include TransfererHelper

  c.before :suite do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:active_record].strategy = :transaction
  end

  c.around do |example|
    Sequel.transaction Sequel::DATABASES, :rollback => :always do
      example.run
    end
  end

  c.before :each do
    DatabaseCleaner.start
  end

  c.after :each do
    DatabaseCleaner.clean
  end
end


