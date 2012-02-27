require 'spec_helper'


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

    context "with #save throws an exception" do
      before do
        save_failure klass
      end
      context ":failure_startegy=>:ignore" do
        let(:options) { {:failure_strategy => :ignore} }
        it "not raise exception" do
          expect{ do_action }.to_not raise_error
        end
      end
      context ":failure_startegy=>:ignore" do
        let(:options) { {:failure_strategy => :rollback} }
        it "raise exception" do
          expect{ do_action }.to raise_error
        end
      end
    end
  end

end
