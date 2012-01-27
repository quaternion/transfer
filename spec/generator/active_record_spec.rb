require 'spec_helper'
require 'generator/shared'


describe Transfer::Generator::ActiveRecord do
  it_should_behave_like "a generator", Transfer::Generator::ActiveRecord, ActiveRecordUser 
end
