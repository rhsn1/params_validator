module ParamsValidator
  module Validator
    class Base
      attr_reader :default

      def initialize(definition={})
      end

      def default?
        instance_variable_defined?('@default')
      end

      def error_message
        raise NotImplementedError
      end

      def valid?(value)
        raise NotImplementedError
      end
    end
  end
end
