module ParamsValidator
  module Validator
    class Presence < Base
      def error_message
        'is empty'
      end

      def valid?(value)
        value.present?
      end
    end
  end
end

