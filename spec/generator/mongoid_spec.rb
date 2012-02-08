require 'spec_helper'
require 'generator/shared'


module Transfer
  module Generator
    describe Mongoid do
      it_should_behave_like "a generator" do
        let!(:generator) { Mongoid }
        let!(:klass) { MongoidUser }
      end
    end
  end
end
