require 'spec_helper'


describe Transfer do
  subject { Transfer }

  it { should respond_to :configs }
  it { should respond_to :configure }


  describe ".configs" do
    subject { Transfer.configs }

    it { should be_instance_of Hash }
    it "raise error if key not exists" do
      expect{ subject[:anything] }.to raise_error
    end
  end


  describe ".configure" do
    after do
      Transfer.configs.clear
    end

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

    context "with empty options" do
      before :all do
        Transfer.configure
      end
      it_should_behave_like "a transfer"
    end

    context "with options :validate => false" do
      before :all do
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

      context "while olivia#save raise exception" do
        before do
          stub.proxy(klass).new do |model|
            stub(model).save{ raise "force exception!" }  if model.id == olivia.id
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

      context "while olivia#save return false" do
        before do
          stub.proxy(klass).new do |model|
            stub(model).save{ false }  if model.id == olivia.id
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

    context "with Transfer.failure = lambda{|model|}" do
      let!(:callback){ lambda{|m|} }
      before do
        Transfer.configure do |c|
          c.failure = callback
        end
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |c|
        context "for #{c}" do
          let!(:klass) { c }
          let!(:model){ klass.new }
          before do
            Fabricate :johnny_hollow
            stub(klass).new{ model }
          end

          it "should not called callback" do
            dont_allow(callback).call
            do_action
          end

          it "should called callback if #save raise exception" do
            instance_of(klass).save { raise "force exception!" }
            stub(callback).call(model).once
            do_action
          end

          it "should called callback if #save return false" do
            instance_of(klass).save { false }
            stub(callback).call(model).once
            do_action
          end
        end
      end
    end

  end

end