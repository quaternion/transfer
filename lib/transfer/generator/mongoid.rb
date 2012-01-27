class Transfer::Generator::Mongoid < Transfer::Generator::Base

  def self.supports? klass
    defined?(Mongoid) && klass.ancestors.include?(Mongoid::Document)
  end

  def transaction
    yield
  rescue
    klass.delete_all
  end

  def create attributes, row, options={}, callbacks={}
    model = klass.new attributes
    model.instance_exec row, &callbacks[:before_save] if callbacks[:before_save]
    save_options = options.select{|key| key == :validate }
    raise unless model.save save_options

    model.instance_exec row, &callbacks[:after_save] if callbacks[:after_save]
    model
  rescue
    options[:failure].call(model) if options[:failure]
    model.instance_exec row, &callbacks[:failure] if callbacks[:failure]
    raise if options[:failure_strategy] == :rollback
    model
  end

end
