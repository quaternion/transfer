require 'rspec'
require 'rr'
require 'fabrication'
require 'transfer'
require 'database_cleaner'

Dir["./spec/support/**/*.rb"].each {|f| require f}

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
    DatabaseCleaner[:sequel, {:connection => SOURCE_DB} ].strategy = :transaction
    DatabaseCleaner[:sequel, {:connection => DESTINATION_DB} ].strategy = :transaction
  end

  c.before :each do
    DatabaseCleaner.start
  end

  c.after :each do
    DatabaseCleaner.clean
  end
end


