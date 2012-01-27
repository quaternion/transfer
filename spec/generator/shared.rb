shared_examples "a generator" do |generator, klass|
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

    it "should return #{klass}" do
      do_action.should be_instance_of klass
    end

    context "with options :failure_strategy =>" do
      context ":ignore" do
        let!(:options) { {:failure_strategy => :ignore} }

        it "not raise exception if model#save return false" do
          instance_of(klass).save { false }
          expect{ do_action }.to_not raise_error
        end
        it "not raise exception if model#save raise exception" do
          instance_of(klass).save { raise "force exception!" }
          expect{ do_action }.to_not raise_error
        end
      end

      context ":rollback" do
        let!(:options) { {:failure_strategy => :rollback} }

        it "not raise exception if model#save return false" do
          instance_of(klass).save { false }
          expect{ do_action }.to raise_error
        end
        it "not raise exception if model#save raise exception" do
          instance_of(klass).save { raise }
          expect{ do_action }.to raise_error
        end
      end
    end

    context "with options :failure" do
      let!(:callback){ lambda{|m|} }
      let!(:options){ {:failure => callback} }
      let!(:model){ klass.new }

      before do
        stub(klass).new{ model }
      end

      it "should not call by default" do
        mock(callback).call(model).never
        do_action
      end
      it "should call callback if model#save return false" do
        instance_of(klass).save { false }
        stub(callback).call(model).once
        do_action
      end
      it "should call callback if model#save raise exception" do
        instance_of(klass).save { raise "force exception!" }
        stub(callback).call(model).once
        do_action
      end
    end

    context "with options" do
      let(:row){ {:value => "Flesh"} }
      let(:callback) { lambda{|row| self.first_name = row[:value]} }

      describe ":before_save" do
        let(:callbacks) { {:before_save => callback} }

        it "should call before_save" do
          do_action.first_name.should == "Flesh"
        end
        it "after create" do
          do_action
          klass.first.first_name.should == "Flesh"
        end
      end
      describe ":after_save" do
        let(:callbacks) { {:after_save => callback} }

        it "should call after_save" do
          do_action.first_name.should == "Flesh"
        end
        it "after create" do
          do_action
          klass.first.first_name.should be_nil
        end
        it "should not call callback if #save return false" do
          instance_of(klass).save{ false }
          do_action.first_name.should be_nil
        end
        it "should not call callback if #save raise exception" do
          instance_of(klass).save{ raise "force exception!" }
          do_action.first_name.should be_nil
        end
      end
    end

  end

end
