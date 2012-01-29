class Transfer::Transferer
  attr_reader :dataset, :klass

  def initialize dataset, klass, &block
    @dataset = dataset
    @klass = klass
    block.arity == 1 ? yield(self) : instance_eval(&block) if block_given?
  end

  def columns
    @columns ||= dataset.columns.each_with_object({}){|i,hash| hash[i]=i if generator.column_present? i }
  end

  def build_attributes source
    attrs = {}
    columns.each do |name, value|
      attrs[name] = case value
        when Proc
          value.call source
        when Symbol
          source[value]
        else
          value
        end
    end
    attrs
  end

  def method_missing symbol, *args, &block
    add_column symbol, block_given? ? block : args[0]
  end

  def process options = {}
    generator.before
    pbar = ProgressBar.new(klass.name, dataset.count)
    generator.transaction do
      dataset.each do |row|
        attributes = build_attributes row
        generator.create attributes, row, options, callbacks
        pbar.inc
      end
    end
    pbar.finish
    generator.after
  end

  def callbacks
    @callbacks ||= {}
  end

  def before_save &block
    callbacks[:before_save] = block
  end

  def after_save &block
    callbacks[:after_save] = block
  end

  def failure &block
    callbacks[:failure] = block
  end

  def generator
    @generator ||= GENERATORS.detect{|g| g.supports? klass}.new klass
  end

  private

  GENERATORS = [
    Transfer::Generator::Sequel,
    Transfer::Generator::ActiveRecord,
    Transfer::Generator::Mongoid,
    Transfer::Generator::Base
  ]


  def add_column key, value
    raise ArgumentError.new("method #{key} in class #{klass} is not defined!") unless generator.column_present?(key)
    raise ArgumentError.new("source column #{value} not exists!") if value.instance_of?(Symbol) and !dataset.columns.include?(value)
    columns[key] = value
  end

  def only *args
    columns.delete_if {|key| !args.include?(key) }
  end

  def except *args
    columns.delete_if {|key| args.include?(key) }
  end

end
