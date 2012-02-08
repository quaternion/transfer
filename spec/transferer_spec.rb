require 'spec_helper'
require 'transferer_shared'

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
            expect{ do_action(klass) { first_name :undefined } }.to raise_error(ArgumentError, "source column #undefined not exists!")
          end

          it "raise error if column not exists in destination class" do
            expect{ do_action(klass) { undefined :fname } }.to raise_error(ArgumentError, "method #undefined in class #{klass} is not defined!")
          end

          it "filter columns with #except" do
            do_action(klass) do
              except :id
            end.should == []
          end

          it "filter columns with #only" do
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
          failure do;end
        end
      end

      [SequelUser, ActiveRecordUser, MongoidUser].each do |klass|
        context klass do
          let!(:klass) { klass }
          its(:callbacks) { should be_include :before_save }
          its(:callbacks) { should be_include :after_save }
          its(:callbacks) { should be_include :failure }
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


      context "if model#save throws an exception" do
        let!(:olivia) { Fabricate :olivia_lufkin }
        before do
          stub.proxy(klass).new do |model|
            save_failure(model) if model.id == olivia.id
            model
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
