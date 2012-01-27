require 'rspec'
require 'rr'
require 'transfer'
require 'ostruct'
require 'fabrication'
# require 'progress_bar'
require 'progressbar'
# require 'progress'
require 'support/source'
require 'support/sequel'
require 'support/active_record'
require 'support/mongoid'
require 'database_cleaner'

RSpec.configure do |c|
  c.mock_with :rr
  # c.before :all do
    # SourceUserMigration.apply SOURCE_DB, :up
    # SequelUserMigration.apply DESTINATION_DB, :up
    # SourceUser.db = SOURCE_DB
    # SequelUser.db = DESTINATION_DB
# 
    # ActiveRecordUserMigration.up
  # end
  
  c.before :suite do
    # SourceUserMigration.apply SOURCE_DB, :up
    # SequelUserMigration.apply DESTINATION_DB, :up
    # SourceUser.db = SOURCE_DB
    # SequelUser.db = DESTINATION_DB

    # {:connection => :two}
    
    # DatabaseCleaner.strategy = :transaction
    # DatabaseCleaner[:sequel].strategy = :truncation
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:active_record].strategy = :transaction
    # DatabaseCleaner[:sequel, {:connection => SOURCE_DB}].strategy = :transaction
    # DatabaseCleaner[:sequel, {:connection => DESTINATION_DB}].strategy = :truncation
    # DatabaseCleaner.clean_with :truncation
  end
  
  c.around do |example|
    Sequel.transaction Sequel::DATABASES, :rollback => :always do
      example.run
    end
  end

  c.before :each do
    # DatabaseCleaner[:sequel].start
    DatabaseCleaner.start
    # supress progress bar output
    any_instance_of(ProgressBar) do |pb|
      stub(pb).inc
      stub(pb).finish
    end
  end

  c.after :each do
    DatabaseCleaner.clean
    # DatabaseCleaner[:sequel].clean
  end
end

module RR
  module Adapters
    module RSpec2

      include RRMethods

      def setup_mocks_for_rspec
        RR.reset
      end
      def verify_mocks_for_rspec
        RR.verify
      end
      def teardown_mocks_for_rspec
        RR.reset
      end

      def have_received(method = nil)
        RR::Adapters::Rspec::InvocationMatcher.new(method)
      end
    end
  end
end

RSpec.configuration.backtrace_clean_patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)

module RSpec
  module Core
    module MockFrameworkAdapter
      include RR::Adapters::RSpec2
    end
  end
end