require 'spec_helper'


module Transfer
  module Generators
    describe ActiveRecord do
      it_should_behave_like "a generator" do
        let!(:generator) { ActiveRecord }
        let!(:klass) { ActiveRecordUser }
      end
    end
  end
end
