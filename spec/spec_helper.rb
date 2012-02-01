require 'rspec'
require 'rr'
require 'fabrication'
require 'transfer'
require 'support/source'
require 'support/sequel'
require 'support/active_record'
require 'support/mongoid'
require 'database_cleaner'

RSpec.configure do |c|
  c.mock_with :rr

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
    # supress progressbar output
    any_instance_of(ProgressBar) do |pb|
      stub(pb).inc
      stub(pb).finish
    end
  end

  c.after :each do
    DatabaseCleaner.clean
  end
end
