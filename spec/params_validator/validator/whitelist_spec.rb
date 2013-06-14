require 'spec_helper'

module ParamsValidator
  module Validator
    describe Whitelist do
      subject { Whitelist.new(:_whitelist => %w[a b]) }

      it 'should return true for a whitelisted value' do
        subject.valid?('a').should be_true
      end

      it 'should return false for non whitelisted value' do
        subject.valid?('c').should be_false
      end
    end
  end
end
