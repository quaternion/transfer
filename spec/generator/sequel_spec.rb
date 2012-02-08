require 'spec_helper'
require 'generator/shared'


module Transfer
  module Generator
    describe Sequel do
      it_should_behave_like "a generator" do
        let!(:generator) { Sequel }
        let!(:klass) { SequelUser }
      end
    end
  end
end
