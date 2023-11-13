# frozen_string_literal: true

class BaseService
  def initialize(args)
    @arguments = args
  end

  def self.call(args)
    new(args).call
  end

  def call
    raise NotImplementedError, 'This is an abstract base method. Implement in your subclass.'
  end

  private

  attr_reader :arguments
end
