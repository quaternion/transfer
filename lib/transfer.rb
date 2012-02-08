require "transfer/version"


module Transfer
  extend self
  autoload :Config, 'transfer/config'
  autoload :Transferer, 'transfer/transferer'

  module Generator
    autoload :Sequel, 'transfer/generator/sequel'
    autoload :ActiveRecord, 'transfer/generator/active_record'
    autoload :Mongoid, 'transfer/generator/mongoid'
    autoload :Base, 'transfer/generator/base'
  end

  def configure name = :default, &block
    config = Config.new
    yield config if block_given?
    configs[name] = config
  end

  def configs
    @configs ||= Hash.new {|hash, key| raise "config #{key} not exists" }
  end

end


def transfer *args, &block
  raise ArgumentError if args.length == 0

  case args[0]
  when Symbol, String
    args[0] = Transfer.configs[args[0].to_sym]
    transfer *args, &block
  when Hash
    transfer :default, *args, &block
  when Transfer::Config
    raise ArgumentError.new("second argument should be Hash!") unless args[1].instance_of?(Hash)
    config, options = args[0], args[1]
    process_keys = [:validate, :failure_strategy, :failure]
    process_options = config.process_options.merge options.select{|key| process_keys.include?(key) }
    sources = options.select{|key| !process_keys.include?(key) }
    sources.each do |key, value|
      dataset = config.connection[key]
      transferer = Transfer::Transferer.new dataset, value, &block
      transferer.process process_options
    end
  end

end
