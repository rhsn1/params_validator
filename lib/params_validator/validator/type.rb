module ParamsValidator
  module Validator
    class Type < Base
      def error_message
        "is not of type #{type}"
      end

      def valid?(value)
        true unless Presence.new.valid?(value)
      end

      private

      def type
        self.class.to_s.split(/type/i).last.downcase
      end
    end

    class TypeInteger < Type
      def valid?(value)
        super || !!Integer(value) rescue false
      end
    end

    class TypeFloat < Type
      def valid?(value)
        super || !!Float(value) rescue false
      end
    end

    class TypeString < Type
      def valid?(value)
        super || value.kind_of?(String)
      end
    end

    class TypeArray < Type
      def valid?(value)
        super || value.kind_of?(Array)
      end
    end

    class TypeHash < Type
      def valid?(value)
        super || value.kind_of?(Hash)
      end
    end
  end
end

