require 'spec_helper'

module ParamsValidator
  module Validator
    describe Presence do
      subject { Presence.new }

      it 'should return true for a non blank value' do
        subject.valid?('a string').should be_true
      end

      it 'should return false for an empty string' do
        subject.valid?('').should be_false
      end

      it 'should return false for nil' do
        subject.valid?(nil).should be_false
      end
    end
  end
end

