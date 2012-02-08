class Transfer::Generator::Mongoid < Transfer::Generator::Base

  def self.supports? klass
    defined?(Mongoid) && klass.ancestors.include?(Mongoid::Document)
  end

  def transaction
    yield
  rescue
    klass.delete_all
  end

  def create attributes, row, options={}
    model = klass.new attributes
    model.instance_exec row, &options[:before_save] if options[:before_save]
    save_options = options.select{|key| key == :validate }
    model.save! save_options

    model.instance_exec row, &options[:after_save] if options[:after_save]
    model
  rescue Exception => e
    model.instance_exec row, e, &options[:failure] if options[:failure]
    raise if options[:failure_strategy] == :rollback
    model
  end

end
