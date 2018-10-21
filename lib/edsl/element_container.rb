require 'delegate'
require_relative 'population'

module EDSL
  # This serves as a handy base class for custom elements, page objects and page sections
  # as this inherits from SimpleDelegator any call that would be valid on the root element
  # or browser is valid on the container object.
  #
  # Using this base class is not a requirement, however code in some modules may assume that
  # methods in this class are available.
  #
  # This allows your object to serve as a proxy for the Watir::Container and be have an API
  # consistent with other elements
  #
  class ElementContainer < ::SimpleDelegator
    include EDSL
    include EDSL::Population

    attr_reader :parent_container
    alias_method :root_element, :__getobj__

    def initialize(element, parent = nil)
      super(element)
      @parent_container = parent
    end
  end
end
