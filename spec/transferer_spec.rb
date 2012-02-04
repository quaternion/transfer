require 'spec_helper'


shared_examples "a transfer johnny hollow" do
  let!(:user) { Fabricate :johnny_hollow }

  it "should change count records from 0 to 1" do
    expect{ do_action }.to change{ klass.count }.from(0).to(1)
  end

  describe "first record" do
    subject { klass.first }

    before do
      do_action do
        first_name :fname
        last_name  :lname
        full_name  {|r| "#{r[:fname]} #{r[:lname]}" }
      end
    end

    it { should be }
    its(:id) { should == user.id }
    its(:first_name) { should == "Johnny" }
    its(:last_name) { should == "Hollow" }
    its(:full_name) { should == "Johnny Hollow" }
  end

  describe "callbacks" do
    subject { klass.first }

    it "should call before_save" do
      do_action do
        before_save do |row|
          self.before_save_value = row[:fname]
        end
      end
      subject.before_save_value == "Johnny"
    end
    it "should call after_save" do
      value = nil
      do_action do
        after_save do |row|
          value = row[:fname]
        end
      end
      value.should == "Johnny"
    end

    context "if #save raise exception" do
      before do
        instance_of(klass).save { raise "force exception!" }
      end

      it "should not call after_save" do
        after_save_value = nil
        do_action do
          after_save do |row|
            after_save_value = row[:fname]
          end
        end
        after_save_value.should be_nil
      end

      it "should called failure callback" do
        value = nil
        do_action do
          failure do |row|
            value = row[:fname]
          end
        end
        value.should == "Johnny"
      end
    end
  end
end

shared_examples "a not transfer johnny hollow" do
  let!(:user) { Fabricate :johnny_hollow }

  it "should count not changed" do
    expect{ do_action }.to_not change{ klass.count }
  end
end

shared_examples "a transfer" do
  context SequelUser do
    let!(:klass) { SequelUser }
    it_should_behave_like "a transfer johnny hollow"
  end
  context ActiveRecordUser do
    let!(:klass) { ActiveRecordUser }
    it_should_behave_like "a transfer johnny hollow"
  end
  context MongoidUser do
    let!(:klass) { MongoidUser }
    it_should_behave_like "a transfer johnny hollow"
  end
end

shared_examples "a not transfer" do
  let!(:user) { Fabricate :johnny_hollow }

  context SequelUser do
    let!(:klass) { SequelUser }
    it_should_behave_like "a not transfer johnny hollow"
  end
  context ActiveRecordUser do
    let!(:klass) { ActiveRecordUser }
    it_should_behave_like "a not transfer johnny hollow"
  end
  context MongoidUser do
    let!(:klass) { MongoidUser }
    it_should_behave_like "a not transfer johnny hollow"
  end
end

shared_examples "a transfer with false validation" do
  context SequelUserWithFalseValidation do
    let!(:klass) { SequelUserWithFalseValidation }
    it_should_behave_like "a transfer johnny hollow"
  end
  context ActiveRecordUserWithFalseValidation do
    let!(:klass) { ActiveRecordUserWithFalseValidation }
    it_should_behave_like "a transfer johnny hollow"
  end
  context MongoidUserWithFalseValidation do
    let!(:klass) { MongoidUserWithFalseValidation }
    it_should_behave_like "a transfer johnny hollow"
  end
end

shared_examples "a not transfer with false validation" do
  let!(:user) { Fabricate :johnny_hollow }

  context SequelUserWithFalseValidation do
    let!(:klass) { SequelUserWithFalseValidation }
    it_should_behave_like "a not transfer johnny hollow"
  end
  context ActiveRecordUserWithFalseValidation do
    let!(:klass) { ActiveRecordUserWithFalseValidation }
    it_should_behave_like "a not transfer johnny hollow"
  end
  context MongoidUserWithFalseValidation do
    let!(:klass) { MongoidUserWithFalseValidation }
    it_should_behave_like "a not transfer johnny hollow"
  end
end


module Transfer
  describe Transferer do
    let!(:dataset) { SOURCE_DB[:source_users] }

    describe "#columns" do
      def do_action klass, &block
        Transferer.new(dataset, klass, &block).columns.keys
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |klass|
        context klass do
          it "with block" do
            do_action(klass) do
              first_name :fname
              last_name  :lname
            end.should == [:id, :first_name, :last_name]
          end

          it "raise error if column not exists in source" do
            expect{ do_action(klass) { first_name :undefined } }.to raise_error(ArgumentError)
          end

          it "raise error if column not exists in destination class" do
            expect{ do_action(klass) { undefined :fname } }.to raise_error(ArgumentError)
          end

          it "remove columns with except" do
            do_action(klass) do
              except :id
            end.should == []
          end

          it "remove columns with except" do
            do_action(klass) do
              first_name :fname
              last_name  :lname
              only :last_name
            end.should == [:last_name]
        end
        end
      end
    end

    describe "#generator" do
      subject { Transferer.new(dataset, @klass).generator }

      it Generator::Sequel do
        @klass = SequelUser
        should be_instance_of Generator::Sequel
      end
      it Generator::ActiveRecord do
        @klass = ActiveRecordUser
        should be_instance_of Generator::ActiveRecord
      end
      it Generator::Mongoid do
        @klass = MongoidUser
        should be_instance_of Generator::Mongoid
      end
    end

    describe "#callbacks" do
      subject do
        Transferer.new dataset, klass do
          before_save do;end
          after_save do;end
        end
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |klass|
        context klass do
          let!(:klass) { klass }
          its(:callbacks) { should be_include :before_save }
          its(:callbacks) { should be_include :after_save }
        end
      end
    end

    describe "#process" do
      def do_action &block
        Transferer.new(dataset, klass, &block).process(options)
      end

      context "with empty options" do
        let!(:options) { {} }
        it_should_behave_like "a transfer"
      end

      context "with options :validate => true" do
        let!(:options) { {:validate => true} }
        it_should_behave_like "a transfer"
      end

      context "with options :validate => false" do
        let!(:options) { {:validate => false} }
        it_should_behave_like "a transfer with false validation"
      end


      context "model#save raise exception" do
        let!(:olivia) { Fabricate :olivia_lufkin }
        before do
          stub.proxy(klass).new do |result|
            stub(result).save { raise "force exception!" } if result.id == olivia.id
            result
          end
        end

        context "with options :failure_strategy => :ignore" do
          let!(:options) { {:failure_strategy => :ignore} }
          it_should_behave_like "a transfer"
        end
        context "with options :failure_strategy => :rollback" do
          let!(:options) { {:failure_strategy => :rollback} }
          it_should_behave_like "a not transfer"
        end
      end

      context "model#save return false" do
        let!(:olivia) { Fabricate :olivia_lufkin }
        before do
          stub.proxy(klass).new do |result|
            stub(result).save { false } if result.id == olivia.id
            result
          end
        end

        context "with options :failure_strategy => :ignore" do
          let!(:options) { {:failure_strategy => :ignore} }
          it_should_behave_like "a transfer"
        end
        context "with options :failure_strategy => :rollback" do
          let!(:options) { {:failure_strategy => :rollback} }
          it_should_behave_like "a not transfer"
        end
      end


    end

  end
end
