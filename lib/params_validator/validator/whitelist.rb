module ParamsValidator
  module Validator
    class Whitelist
      def initialize(definition)
        @whitelist = definition.delete(:_whitelist).map(&:to_s).to_set
      end

      def error_message
      end

      def valid?(value)
        whitelist.include?(value)
      end

      private

      attr_reader :whitelist
    end
  end
end

