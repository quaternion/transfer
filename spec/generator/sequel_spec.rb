require 'spec_helper'
require 'generator/shared'


describe Transfer::Generator::Sequel do
  it_should_behave_like "a generator", Transfer::Generator::Sequel, SequelUser 
end