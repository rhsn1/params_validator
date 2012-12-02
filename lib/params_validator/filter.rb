module ParamsValidator
  module Filter
    extend ActiveSupport::Inflector

    def self.validate_params(params, definition)
      errors = {}
      definition.each do |field, validation_definition|
        errors = validate_field(field, params, validation_definition[:_with], errors)

        validation_definition.reject {|k,v| k == :_with }.each do |nested_field, nested_validation_definition|
          validate_params(params[field.to_s], { nested_field => nested_validation_definition })
        end
      end
      if errors.count > 0
        exception = InvalidParamsException.new
        exception.errors = errors
        raise exception
      end
    end

    private

    def self.validate_field(field, params, validators, errors)
      return errors unless validators
      validators.each do |validator_name|
        camelized_validator_name = self.camelize(validator_name)
        begin
          validator = constantize("ParamsValidator::Validator::#{camelized_validator_name}")
          value = params.is_a?(Hash) ? params[field.to_s] : nil
          unless validator.valid?(value)
            errors[field] = validator.error_message
          end
        rescue NameError
          raise InvalidValidatorException.new(validator_name)
        end
      end
      errors
    end
  end
end

