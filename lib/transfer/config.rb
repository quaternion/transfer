require 'sequel'

module Transfer
  class Config
    def initialize data = {}
      data.each do |key, value|
        send "#{key}=", value
      end
    end

    def connection_options
      @connection_options ||= {}
    end

    def process_options
      @process_options ||= { :validate => true, :failure_strategy => :ignore }
    end

    def connection
      @connection ||= Sequel.connect connection_options
    end

    def method_missing name, *args, &block
      /^((validate|failure_strategy|failure)|\w+)(=)?$/.match name
      opt = $2 ? process_options : connection_options
      if block_given?
        opt[$1.to_sym] = block
      else
        $3 ? opt[$1.to_sym] = args[0] : opt[name]
      end
    end
  end

end
