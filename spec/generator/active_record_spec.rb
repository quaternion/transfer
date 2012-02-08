require 'spec_helper'
require 'generator/shared'


module Transfer
  module Generator
    describe ActiveRecord do
      it_should_behave_like "a generator" do
        let!(:generator) { ActiveRecord }
        let!(:klass) { ActiveRecordUser }
      end
    end
  end
end
