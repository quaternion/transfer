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

    context "if #save throws an exception" do
      include_context "stub klass model"
      before do
        save_failure klass
      end

      it "should not call after_save" do
        do_action do
          after_save do |row|
            self.dynamic_value = row[:fname]
          end
        end
        model.dynamic_value.should be_nil
      end
      it "should called failure callback" do
        do_action do
          failure do |row|
            self.dynamic_value = row[:fname]
          end
        end
        model.dynamic_value.should == "Johnny"
      end
      it "should pass correct exception to failure callback" do
        do_action do
          failure do |row, exception|
            self.dynamic_value = exception
          end
        end
        model.dynamic_value.message.should == "force exception!"
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

shared_context "stub klass model" do
  let!(:model) { klass.new }
  before do
    stub(klass).new { model }
  end
end
