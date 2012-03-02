class Transfer::Generators::Sequel < Transfer::Generators::Base

  def self.supports? klass
    defined?(Sequel) && klass.ancestors.include?(Sequel::Model)
  end

  def before
    klass.unrestrict_primary_key
    @strict_param_setting = klass.strict_param_setting
    klass.strict_param_setting = false
    klass.set_restricted_columns if @restricted_columns = klass.restricted_columns
    klass.set_allowed_columns if @allowed_columns = klass.allowed_columns
  end

  def after
    klass.restrict_primary_key
    klass.strict_param_setting = @strict_param_setting
    klass.set_restricted_columns *@restricted_columns if @restricted_columns
    klass.set_allowed_columns *@allowed_columns if @allowed_columns
  end

  def column_present? name
    super name || klass.columns.include?(name.to_sym)
  end

  def transaction &block
    klass.db.transaction :savepoint => true, &block
  end

  def create attributes, row, options={}, callbacks={}
    model = klass.new attributes
    model.instance_exec(row, &callbacks[:before_save]) if callbacks[:before_save]

    save_options = options.select{|key| key == :validate }
    save_options[:raise_on_failure] = true

    model.save save_options
    model.instance_exec(row, &callbacks[:after_save]) if callbacks[:after_save]
    options[:success].call(model, row) if options[:success]
    model
  rescue Exception => e
    options[:failure].call(model, row, e) if options[:failure]
    raise Sequel::Rollback if options[:failure_strategy] == :rollback
    model
  end

end
