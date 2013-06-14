require 'spec_helper'

describe ParamsValidator::Filter do
  it 'should call Integer validator' do
    integer = double(ParamsValidator::Validator::TypeInteger)
    integer.should_receive(:valid?).with(42) { true }
    ParamsValidator::Validator::TypeInteger.stub(:new) { integer }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 42 },
      { :field_name => { :_with => [:type_integer] } }
    )
  end

  it 'should call Float validator' do
    float = double(ParamsValidator::Validator::TypeFloat)
    float.should_receive(:valid?).with(4.2) { true }
    ParamsValidator::Validator::TypeFloat.stub(:new) { float }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 4.2 },
      { :field_name => { :_with => [:type_float] } }
    )
  end

  it 'should call String validator' do
    string = double(ParamsValidator::Validator::TypeString)
    string.should_receive(:valid?).with('a string') { true }
    ParamsValidator::Validator::TypeString.stub(:new) { string }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:type_string] } }
    )
  end

  it 'should call Hash validator' do
    hash = double(ParamsValidator::Validator::TypeHash)
    hash.should_receive(:valid?).with({}) { true }
    ParamsValidator::Validator::TypeHash.stub(:new) { hash }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => {} },
      { :field_name => { :_with => [:type_hash] } }
    )
  end

  it 'should call Array validatou' do
    array = double(ParamsValidator::Validator::TypeArray)
    array.should_receive(:valid?).with([]) { true }
    ParamsValidator::Validator::TypeArray.stub(:new) { array }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => [] },
      { :field_name => { :_with => [:type_array] } }
    )
  end

  it 'should call Presence validator' do
    presence = double(ParamsValidator::Validator::Presence)
    presence.should_receive(:valid?).with('a string') { true }
    ParamsValidator::Validator::Presence.stub(:new) { presence }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:presence] } }
    )
  end

  it 'should call Whitelist constructor' do
    whitelist = double(ParamsValidator::Validator::Whitelist)
    whitelist.stub(:valid?) { true }
    ParamsValidator::Validator::Whitelist.should_receive(:new).with(kind_of(Hash)) { whitelist }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:whitelist] } }
    )
  end

  it 'should call Whitelist validator' do
    whitelist = double(ParamsValidator::Validator::Whitelist)
    whitelist.should_receive(:valid?).with('a string') { true }
    ParamsValidator::Validator::Whitelist.should_receive(:new) { whitelist }
    ParamsValidator::Filter.sanitize_params(
      { 'field_name' => 'a string' },
      { :field_name => { :_with => [:whitelist] } }
    )
  end

  it 'should raise InvalidParamsException when validator returns false' do
    integer = double(ParamsValidator::Validator::TypeInteger)
    integer.stub(:error_message) { '' }
    integer.stub(:valid?) { false }
    ParamsValidator::Validator::TypeInteger.stub(:new) { integer }
    lambda do
      ParamsValidator::Filter.sanitize_params(
        { 'field_name' => 42 },
        { :field_name => { :_with => [:type_integer] } }
      )
    end.should raise_error ParamsValidator::InvalidParamsException
  end

  it 'should not raise InvalidParamsException when a validator has a default value' do
    expect do
      ParamsValidator::Filter.sanitize_params(
        { 'field_name' => 'a' },
        { :field_name => { :_with => [:whitelist], :_whitelist => [:b], :_default => :c } }
      )
    end.to_not raise_error(ParamsValidator::InvalidParamsException)
  end

  it 'should raise InvalidValidatorException when invalid filter name is used' do
    lambda do
      ParamsValidator::Filter.sanitize_params(
        { 'field_name' => 42 },
        { :field_name => { :_with => [:type_invalid] } }
      )
    end.should raise_error ParamsValidator::InvalidValidatorException
  end

  context 'nested fields' do
    it 'should allow nested parameters' do
      integer = double(ParamsValidator::Validator::TypeInteger)
      integer.should_receive(:valid?).with(1) { true }
      ParamsValidator::Validator::TypeInteger.stub(:new) { integer }
      float = double(ParamsValidator::Validator::TypeFloat)
      float.should_receive(:valid?).with(2.0) { true }
      ParamsValidator::Validator::TypeFloat.stub(:new) { float }
      ParamsValidator::Filter.sanitize_params(
        { 'level_1' => { 'integer_field' => 1, 'float_field' => 2.0 } },
        { :level_1 => { :_with => [:type_hash],
                        :integer_field => { :_with => [:type_integer] },
                        :float_field => { :_with => [:type_float] } } }
      )
    end

    it 'should not fail when parent param has no _with item' do
      lambda do
        ParamsValidator::Filter.sanitize_params(
          { 'level_1' => { 'integer_field' => 1 } },
          { :level_1 => { :integer_field => { :_with => [:type_integer] } } }
        )
      end.should_not raise_error
    end

    it 'should not raise when parent param is no hash' do
      lambda do
        ParamsValidator::Filter.sanitize_params(
          { 'level_1' => 1 },
          { 'level_1' => { :integer_field => { :_with => [:type_integer] } } }
        )
      end.should_not raise_error
    end

    it 'should raise when nested is required but parent param is no hash' do
      lambda do
        ParamsValidator::Filter.sanitize_params(
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
        ParamsValidator::Filter.sanitize_params(
          { 'l1' => { 'l2' => { 'i' => 1, 'l3' => { 'f' => 2.0 } } } },
          defs
        )
      end.should_not raise_error
      lambda do
        ParamsValidator::Filter.sanitize_params(
          { 'l1' => { 'l2' => { 'i' => 1, 'l3' => { } } } },
          defs
        )
      end.should raise_error ParamsValidator::InvalidParamsException
    end

  end
end

