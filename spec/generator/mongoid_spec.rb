require 'spec_helper'
require 'generator/shared'


describe Transfer::Generator::Mongoid do
  it_should_behave_like "a generator", Transfer::Generator::Mongoid, MongoidUser 
end
