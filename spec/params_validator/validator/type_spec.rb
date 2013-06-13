require 'spec_helper'

module ParamsValidator
  module Validator
    describe ParamsValidator::Validator::TypeInteger do
      subject { TypeInteger.new }

      it 'should return true for Fixnum value' do
        subject.valid?(42).should be_true
      end

      it 'should return true for String value with integer content' do
        subject.valid?('42').should be_true
      end

      it 'should return false for String value with non integer content' do
        subject.valid?('true').should be_false
      end

      it 'should return false for String value with non float content' do
        subject.valid?('4.2').should be_false
      end

      it 'should return true for empty String value' do
        subject.valid?('').should be_true
      end

      it 'should return true for nil value' do
        subject.valid?(nil).should be_true
      end
    end

    describe TypeFloat do
      subject { TypeFloat.new }

      it 'should return true for Float value' do
        subject.valid?(4.2).should be_true
      end

      it 'should return true for String value with float content' do
        subject.valid?('4.2').should be_true
      end

      it 'should return false for String value with non float content' do
        subject.valid?('true').should be_false
      end

      it 'should return true for empty String value' do
        subject.valid?('').should be_true
      end

      it 'should return true for nil value' do
        subject.valid?(nil).should be_true
      end
    end

    describe TypeString do
      subject { TypeString.new }

      it 'should return true for Array value' do
        subject.valid?('a string').should be_true
      end

      it 'should return false for non String value' do
        subject.valid?(42).should be_false
      end

      it 'should return true for nil value' do
        subject.valid?(nil).should be_true
      end
    end

    describe TypeArray do
      subject { TypeArray.new }

      it 'should return true for Array value' do
        subject.valid?([]).should be_true
      end

      it 'should return false for non Array value' do
        subject.valid?('a string').should be_false
      end

      it 'should return true for empty String value' do
        subject.valid?('').should be_true
      end

      it 'should return true for nil value' do
        subject.valid?(nil).should be_true
      end
    end

    describe TypeHash do
      subject { TypeHash.new }

      it 'should return true for Hash value' do
        subject.valid?({}).should be_true
      end

      it 'should return false for non Hash value' do
        subject.valid?('a string').should be_false
      end

      it 'should return true for empty String value' do
        subject.valid?('').should be_true
      end

      it 'should return true for nil value' do
        subject.valid?(nil).should be_true
      end
    end
  end
end

