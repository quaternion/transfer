class Transfer::Generators::Base
  attr_accessor :klass

  def self.supports? klass
    raise "Not Yet Implemented!"
  end

  def initialize klass
    @klass = klass
  end

  def before
  end

  def after
  end

  def create attributes, row, options={}, callbacks={}
    raise "Not Yet Implemented!"
  end

  def column_present? name
    klass.method_defined? name
  end

end
