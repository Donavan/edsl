require 'erb'
module EDSL
  module PageObject
    DEFAULT_PAGE_READY_LIMIT = 30

    module WithURL
      #
      # Set some values that can be used within the class.  This is
      # typically used to provide values that help build dynamic urls in
      # the page_url method
      #
      # @param [Hash] the value to set the params
      #
      def params=(the_params)
        @params = the_params
      end

      #
      # Return the params that exist on this page class
      #
      def params
        @params ||= {}
      end

      def page_url(url)
        define_method("goto") do
          browser.goto self.page_url_value
        end

        define_method('page_url_value') do
          lookup        = url.kind_of?(Symbol) ? self.send(url) : url
          erb           = ::ERB.new(%Q{#{lookup}})
          merged_params = self.class.instance_variable_get("@merged_params")
          params        = merged_params ? merged_params : self.class.params
          erb.result(binding)
        end
      end
    end

    # This class represents an entire page within the browser.
    #
    # Using this base class is not a requirement, however code in some modules may assume that
    # methods in this class are available when they're dealing with pages
    #
    # This allows your object to serve as a proxy for the browser and mirror it's API.
    #
    class Page < ElementContainer
      attr_accessor :page_ready_limit
      alias_method :browser, :root_element
      extend WithURL

      # Create a new page.
      def initialize(web_browser, visit = false)
        super(web_browser, nil)
        @page_ready_limit = DEFAULT_PAGE_READY_LIMIT
        goto if visit
      end

      # An always safe to call ready function. Subclasses should implement the _ready? method
      # to provide an actual implementation.
      def ready?
        return _ready?
      rescue
        return false
      end

      # Block until the page is ready then yield / return self.
      #
      # If a block is given the page will be yielded to it.
      #
      def when_ready(limit = nil, &block)
        begin
          Watir::Wait.until(limit || page_ready_limit) { _ready? }
        rescue Timeout::Error
          raise Timeout::Error, "Timeout limit #{limit} reached waiting for #{self.class} to be ready"
        end
        yield self if block_given?
        self
      end

      private

      # Subclasses should override this with something that checks the state of the page.
      def _ready?
        true
      end
    end
  end
end
