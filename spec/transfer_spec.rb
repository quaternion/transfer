require 'spec_helper'
require 'transferer_shared'

describe Transfer do
  subject { Transfer }

  it { should respond_to :configs }
  it { should respond_to :configure }

  before do
    Transfer.configs.clear
  end

  describe ".configs" do
    subject { Transfer.configs }

    it { should be_instance_of Hash }
    it "raise error if key not exists" do
      expect{ subject[:anything] }.to raise_error
    end
  end

  describe ".configure" do
    context ":default" do
      subject { Transfer.configs[:default] }
      before do
        Transfer.configure {|c| c.host = "default"}
      end

      it { should be_instance_of Transfer::Config }
      its(:host) { should == "default" }
    end

    context ":named" do
      subject { Transfer.configs[:named] }
      before do
        Transfer.configure(:named) {|c| c.host = "named" }
      end

      it { should be_instance_of Transfer::Config }
      its(:host) { should == "named" }
    end
  end

  describe "transfer" do
    def do_action &block
      transfer :source_users => klass, &block
    end

    before do
      instance_of(Transfer::Config).connection { SOURCE_DB }
    end

    context "with empty" do
      before do
        Transfer.configure
      end
      it_should_behave_like "a transfer"
    end

    context "with :validate => false" do
      before do
        Transfer.configure do |config|
          config.validate = false
        end
      end
      it_should_behave_like "a transfer with false validation"
    end

    context "olivia_lufkin and johnny_hollow" do
      let!(:olivia) { Fabricate :olivia_lufkin }
      before do
        Transfer.configure do |config|
          config.failure_strategy = failure_strategy
        end
      end

      context "while olivia#save throws an exception" do
        before do
          stub.proxy(klass).new do |model|
            save_failure(model) if model.id == olivia.id
            model
          end
        end

        context "with Transfer.failure_strategy = :ignore" do
          let!(:failure_strategy) { :ignore }
          it_should_behave_like "a transfer"
        end
        context "with Transfer.failure_strategy = :rollback" do
          let!(:failure_strategy) { :rollback }
          it_should_behave_like "a not transfer"
        end
      end
    end

    context "with callbacks" do
      include_context "stub klass model"
      let!(:user) { Fabricate :johnny_hollow }
      before do
        @config = Transfer.configure do |c|
          c.before {}
          c.success {}
          c.failure {}
          c.after {}
        end
        @dataset = @config.connection[:source_users]
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |klass|
        context klass do
          let!(:klass) { klass }
          it "should call before" do
            stub(@config.before).call(klass, @dataset).once
            do_action
          end
          it "should call after" do
            stub(@config.after).call(klass, @dataset).once
            do_action
          end
          it "should call success" do
            stub(@config.success).call(model, user.values).once
            do_action
          end
          it "should not call failure" do
            stub(@config.failure).call.never
            do_action
          end
          context "if save failure" do
            let!(:exception) { RuntimeError.new }
            before do
              save_failure klass
              stub(RuntimeError).new { exception }
            end
            it "should call before" do
              stub(@config.before).call(klass, @dataset).once
              do_action
            end
            it "should call after" do
              stub(@config.after).call(klass, @dataset).once
              do_action
            end
            it "should not call success" do
              stub(@config.success).call.never
              do_action
            end
            it "should call failure" do
              stub(@config.failure).call(model, user.values, exception).once
              do_action
            end
          end
        end
      end
    end

    describe "override global options" do
      before do
        Transfer.configure do |c|
          c.validate = true
          c.failure_strategy = :ignore
        end
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |klass|
        it "for #{klass}" do
          instance_of(Transfer::Transferer).process(:validate => false, :failure_strategy => :rollback).once
          transfer :source_users => klass, :validate => false, :failure_strategy => :rollback
        end
      end
    end

  end

end
