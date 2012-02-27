class Transfer::Generators::Mongoid < Transfer::Generators::Base

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
    model.save! save_options

    options[:success].call(model, row) if options[:success]
    model.instance_exec row, &callbacks[:after_save] if callbacks[:after_save]
    model
  rescue Exception => e
    options[:failure].call(model, row, e) if options[:failure]
    raise if options[:failure_strategy] == :rollback
    model
  end

end
