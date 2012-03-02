require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("godfather")
end

class MongoidUser
  include Mongoid::Document

  field :first_name, :type => String
  field :last_name, :type => String
  field :full_name, :type => String
  field :before_save_value, :type => String
  field :protected_value, :type => String

  attr_accessor :dynamic_value
  attr_protected :protected_value
end


class MongoidUserWithFalseValidation
  include Mongoid::Document

  field :first_name, :type => String
  field :last_name, :type => String
  field :full_name, :type => String
  field :before_save_value, :type => String
  field :protected_value, :type => String

  attr_accessor :dynamic_value
  attr_protected :protected_value

  validate :fake

  def fake
    errors.add :fake, 'fake'
  end
end
