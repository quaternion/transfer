class Transfer::Generator::ActiveRecord < Transfer::Generator::Base

  def self.supports? klass
    defined?(ActiveRecord) && klass.ancestors.include?(ActiveRecord::Base)
  end

  def before
  end

  def after
  end

  def column_present? name
    super(name) || klass.column_names.include?(name.to_s)
  end

  def transaction &block
    klass.transaction &block
  end

  def create attributes, row, options={}, callbacks={}
    model = klass.new attributes, :without_protection => true

    model.instance_exec row, &callbacks[:before_save] if callbacks[:before_save]
    save_options = options.select{|key| key == :validate }

    raise unless model.save save_options
    model.instance_exec row, &callbacks[:after_save] if callbacks[:after_save]
    model
  rescue
    options[:failure].call(model) if options[:failure]
    model.instance_exec row, &callbacks[:failure] if callbacks[:failure]
    raise ActiveRecord::Rollback if options[:failure_strategy] == :rollback
    model
  end

end
