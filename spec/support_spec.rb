require 'spec_helper'

describe "support" do
  
  context SequelUserWithFalseValidation do
    it "#save" do
      subject.save(:raise_on_failure => false).should be_false
    end
  end
  
  context ActiveRecordUserWithFalseValidation do
    its(:save) { should be_false }
  end
  
  context MongoidUserWithFalseValidation do
    its(:save) { should be_false }
  end
  
end
