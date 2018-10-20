require 'delegate'
module EDSL
  # This serves as a handy base class for custom elements and page objects
  # as this inherits from SimpleDelegator it needs one parameter when initialized,
  # this parameter should be an object that implements the same methods as Watir::Container
  #
  # This allows your object to serve as a proxy for the Watir::Container and be have an API
  # consistent with other elements
  #
  class ElementContainer < ::SimpleDelegator
    include EDSL
  end
end
