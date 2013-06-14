module ParamsValidator
  module Validator
    class Whitelist
      attr_reader :default

      def initialize(definition)
        @default = definition[:_default] if definition.key?(:_default)
        @whitelist = definition[:_whitelist].map(&:to_s).to_set
      end

      def default?
        instance_variable_defined?('@default')
      end

      def error_message
        'is invalid'
      end

      def valid?(value)
        whitelist.include?(value)
      end

      private

      attr_reader :whitelist
    end
  end
end

