require 'spec_helper'


module Transfer
  module Generators
    describe Mongoid do
      it_should_behave_like "a generator" do
        let!(:generator) { Mongoid }
        let!(:klass) { MongoidUser }
      end
    end
  end
end
