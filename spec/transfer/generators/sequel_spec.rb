require 'spec_helper'


module Transfer
  module Generators
    describe Sequel do
      it_should_behave_like "a generator" do
        let!(:generator) { Sequel }
        let!(:klass) { SequelUser }
      end
    end
  end
end
