require 'spec_helper'
require 'transferer_shared'


shared_examples "a generator" do
  subject { generator.new klass }

  it { should respond_to :create }
  it { should respond_to :column_present? }

  describe "#column_present?" do
    it :first_name do
      subject.column_present?(:first_name).should be_true
    end
    it :last_name do
      subject.column_present?(:last_name).should be_true
    end
    it :full_name do
      subject.column_present?(:full_name).should be_true
    end
    it :before_save_value do
      subject.column_present?(:before_save_value).should be_true
    end
    it :dynamic_value do
      subject.column_present?(:dynamic_value).should be_true
    end
    it :undefined do
      subject.column_present?(:undefined).should be_false
    end
  end

  describe "#create" do
    let(:attributes) {{}}
    let(:row) {{}}
    let(:options) {{}}
    let(:callbacks) {{}}

    def do_action
      subject.create attributes, row, options, callbacks
    end

    it "should return correct type" do
      do_action.should be_instance_of klass
    end

    context "with options" do
      context "failure_strategy" do
        describe ":ignore" do
          let(:options) { {:failure_strategy => :ignore} }
          it "not raise exception if model#save throws an exception" do
            save_failure klass
            expect{ do_action }.to_not raise_error
          end
        end

        describe ":rollback" do
          let(:options) { {:failure_strategy => :rollback} }
          it "raise exception if model#save throws an exception" do
            save_failure klass
            expect{ do_action }.to raise_error
          end
        end
      end
    end

    context "with callbacks" do
      let(:row){ {:value => "flesh"} }
      let(:callback) { lambda{|row| self.dynamic_value = row[:value]} }

      it "should dynamic_value be nil" do
        do_action.dynamic_value.should be_nil
      end

      describe ":before_save" do
        let(:callbacks) { {:before_save => callback} }
        it "should call" do
          do_action.dynamic_value.should == "flesh"
        end
        it "should call if #save throws an exception" do
          save_failure klass
          do_action.dynamic_value.should == "flesh"
        end
      end
      describe ":after_save" do
        let(:callbacks) { {:after_save => callback} }
        it "should call after_save" do
          do_action.dynamic_value.should == "flesh"
        end
        it "should not call if #save throws an exception" do
          save_failure klass
          do_action.dynamic_value.should be_nil
        end
      end
    end

  end

end
