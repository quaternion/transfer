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

  def create attributes, row, options={}
    model = klass.new attributes, :without_protection => true

    model.instance_exec row, &options[:before_save] if options[:before_save]
    save_options = options.select{|key| key == :validate }

    model.save! save_options
    model.instance_exec row, &options[:after_save] if options[:after_save]
    model
  rescue Exception => e
    model.instance_exec row, e, &options[:failure] if options[:failure]
    raise ActiveRecord::Rollback if options[:failure_strategy] == :rollback
    model
  end

end
