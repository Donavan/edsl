module EDSL
  module PageObject
    # This class represents a section of the dom contained within a root element.
    #
    # Using this base class is not a requirement, however code in some modules may assume that
    # methods in this class are available when they're dealing with sections
    #
    # This allows your object to serve as a proxy for the element and mirror it's API.
    #
    class Section < ElementContainer
      # Create a new section
      def initialize(element, parent)
        super(element, parent)
      end

      def browser
        @browser ||= _find_browser_via(parent_container)
      end

      def _find_browser_via(container)
        raise ScriptError, "Could not locate a browser in #{self.class}." if container.nil?
        return container.browser if container.respond_to?(:browser)
        _find_browser_via(container.parent_container)
      end
    end

    EDSL.extend_dsl {
      def section(name, section_class, opts)
        element(name, { how: :div, assign_method: :populate_with,
                        wrapper_fn: lambda { |element, _container| section_class.new(element, self) } }.merge(opts))
      end

      def sections(name, section_class, opts)
        i_sel = opts.delete(:item)
        item_how = i_sel.delete(:how)
        default_method = lambda { |_name, container| container.send(item_how, i_sel).map { |i| section_class.new(i, self) } }
        element(name, { how: :div,
                        default_method:  default_method }.merge(opts))
      end
    }
  end
end