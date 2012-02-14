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

      describe "#failure" do
        context "with block" do
          before do
            subject.failure {}
          end
          its(:failure) { should be_instance_of Proc }
          its(:process_options) { should include(:failure) }
          its(:connection_options) { should_not include(:failure) }
        end
      end

      describe "#before" do
        before do
          subject.before {}
        end
        its(:before) { should be_instance_of Proc }
        its(:process_options) { should include(:before) }
        its(:connection_options) { should_not include(:before) }
      end

      describe "#after" do
        before do
          subject.after {}
        end
        its(:after) { should be_instance_of Proc }
        its(:process_options) { should include(:after) }
        its(:connection_options) { should_not include(:after) }
      end

      describe "#success" do
        before do
          subject.success {}
        end
        its(:success) { should be_instance_of Proc }
        its(:process_options) { should include(:success) }
        its(:connection_options) { should_not include(:success) }
      end

      describe "#other=" do
        before do
          subject.host = "localhost"
        end
        its(:host) { should == "localhost" }
        its(:connection_options) { should include(:host => "localhost") }
        its(:process_options) { should_not include(:host) }
      end

      describe "#other &block" do
        before do
          subject.host {}
        end
        its(:host) { should be_instance_of Proc }
        its(:connection_options) { should include(:host) }
        its(:process_options) { should_not include(:host) }
      end
    end
  end
end
