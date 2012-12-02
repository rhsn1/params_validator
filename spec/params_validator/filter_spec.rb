require 'spec_helper'

describe ParamsValidator::Filter do
  it 'should call Integer validator' do
    ParamsValidator::Validator::TypeInteger.should_receive(:valid?).with(42) { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => 42 },
      { :field_name => { :_with => [:type_integer] } }
    )
  end

  it 'should call Float validator' do
    ParamsValidator::Validator::TypeFloat.should_receive(:valid?).with(4.2) { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => 4.2 },
      { :field_name => { :_with => [:type_float] } }
    )
  end

  it 'should call String validator' do
    ParamsValidator::Validator::TypeString.should_receive(:valid?).with('a string') { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:type_string] } }
    )
  end

  it 'should call Hash validator' do
    ParamsValidator::Validator::TypeHash.should_receive(:valid?).with({}) { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => {} },
      { :field_name => { :_with => [:type_hash] } }
    )
  end

  it 'should call Array validator' do
    ParamsValidator::Validator::TypeArray.should_receive(:valid?).with([]) { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => [] },
      { :field_name => { :_with => [:type_array] } }
    )
  end

  it 'should call Presence validator' do
    ParamsValidator::Validator::Presence.should_receive(:valid?).with('a string') { true }
    ParamsValidator::Filter.validate_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:presence] } }
    )
  end

  it 'should raise InvalidParamsException when validator returns false' do
    ParamsValidator::Validator::TypeInteger.stub(:valid?) { false }
    lambda do
      ParamsValidator::Filter.validate_params(
        { 'field_name' => 42 },
        { :field_name => { :_with => [:type_integer] } }
      )
    end.should raise_error ParamsValidator::InvalidParamsException
  end

  it 'should raise InvalidValidatorException when invalid filter name is used' do
    lambda do
      ParamsValidator::Filter.validate_params(
        { 'field_name' => 42 },
        { :field_name => { :_with => [:type_invalid] } }
      )
    end.should raise_error ParamsValidator::InvalidValidatorException
  end

  context 'nested fields' do
    it 'should allow nested parameters' do
      ParamsValidator::Validator::TypeInteger.should_receive(:valid?).with(1) { true }
      ParamsValidator::Validator::TypeFloat.should_receive(:valid?).with(2.0) { true }
      ParamsValidator::Filter.validate_params(
        { 'level_1' => { 'integer_field' => 1, 'float_field' => 2.0 } },
        { :level_1 => { :_with => [:type_hash],
                        :integer_field => { :_with => [:type_integer] },
                        :float_field => { :_with => [:type_float] } } }
      )
    end

    it 'should not fail when parent param has no _with item' do
      lambda do
        ParamsValidator::Filter.validate_params(
          { 'level_1' => { 'integer_field' => 1 } },
          { :level_1 => { :integer_field => { :_with => [:type_integer] } } }
        )
      end.should_not raise_error
    end

    it 'should not raise when parent param is no hash' do
      lambda do
        ParamsValidator::Filter.validate_params(
          { 'level_1' => 1 },
          { 'level_1' => { :integer_field => { :_with => [:type_integer] } } }
        )
      end.should_not raise_error
    end

    it 'should raise when nested is required but parent param is no hash' do
      lambda do
        ParamsValidator::Filter.validate_params(
          { 'level_1' => 1 },
          { 'level_1' => { :integer_field => { :_with => [:presence] } } }
        )
      end.should raise_error ParamsValidator::InvalidParamsException
    end

    it 'should allow unlimited nested parameters' do
      defs = {
        :l1 => {
          :_with => [:type_hash],
          :l2 => {
            :_with => [:presence, :type_hash],
            :i => { :_with => [:type_integer] },
            :l3 => {
              :_with => [:presence, :type_hash],
              :f => { :_with => [:type_float] },
            }
          }
        }
      }
      lambda do
        ParamsValidator::Filter.validate_params(
          { 'l1' => { 'l2' => { 'i' => 1, 'l3' => { 'f' => 2.0 } } } },
          defs
        )
      end.should_not raise_error
      lambda do
        ParamsValidator::Filter.validate_params(
          { 'l1' => { 'l2' => { 'i' => 1, 'l3' => { } } } },
          defs
        )
      end.should raise_error ParamsValidator::InvalidParamsException
    end

  end
end

