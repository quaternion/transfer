require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("godfather")
end

class MongoidUser
  include Mongoid::Document
  attr_accessor :dynamic_value

  field :first_name, :type => String
  field :last_name, :type => String
  field :full_name, :type => String
  field :before_save_value, :type => String
end


class MongoidUserWithFalseValidation
  include Mongoid::Document
  attr_accessor :dynamic_value

  field :first_name, :type => String
  field :last_name, :type => String
  field :full_name, :type => String
  field :before_save_value, :type => String

  validate :fake

  def fake
    errors.add :fake, 'fake'
  end
end
