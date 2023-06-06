# frozen_string_literal: true

module Callable
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def call(...)
      new(...).call
    end
  end
end
