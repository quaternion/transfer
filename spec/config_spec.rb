require 'spec_helper'


module Transfer
  describe Config do
    subject { Config.new options }

    describe "#process_options" do
      context "by default" do
        let!(:options) { {} }
        its(:process_options) { should == { :validate => true, :failure_strategy => :ignore } }
      end
      context "set options" do
        let!(:options) { { :validate => false, :failure_strategy => :rollback, :failure => lambda{} } }
        its(:process_options) { should == options }
      end
    end

    describe "#connection_options" do
      context "by default" do
        let!(:options) { {} }
        its(:connection_options) { should be_empty }
      end
      context "set options" do
        let!(:options) { { :adapter => "sqlite", :host => "localhost" } }
        its(:connection_options) { should == options }
      end
    end

    describe "#connection" do
      let!(:options) { { :adapter => "sqlite", :host => "localhost" } }
      before do
        stub(Sequel).connect(options) { :bingo }
      end
      its(:connection) { should be :bingo }
    end

    describe "added new options" do
      let!(:options) { {} }

      describe "#validate" do
        before do
          subject.validate = false
        end
        its(:validate) { should be_false }
        its(:process_options) { should include(:validate => false) }
        its(:connection_options) { should_not include(:validate) }
      end

      describe "#failure_strategy" do
        before do
          subject.failure_strategy = :rollback
        end
        its(:failure_strategy) { should == :rollback }
        its(:process_options) { should include(:failure_strategy => :rollback) }
        its(:connection_options) { should_not include(:failure_strategy) }
      end

      describe "#failure_callback" do
        context "with lambda" do
          before do
            subject.failure = lambda{|model|}
          end
          its(:failure) { should be_instance_of Proc }
          its(:process_options) { should include(:failure) }
          its(:connection_options) { should_not include(:failure) }
        end

        context "with block" do
          before do
            subject.failure do |model|
            end
          end
          its(:failure) { should be_instance_of Proc }
          its(:process_options) { should include(:failure) }
          its(:connection_options) { should_not include(:failure) }
        end
      end

      describe "to connection_params" do
        before do
          subject.host = "localhost"
        end
        its(:host) { should == "localhost" }
        its(:connection_options) { should include(:host => "localhost") }
        its(:process_options) { should_not include(:host) }
      end
    end
  end
end
