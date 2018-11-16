# Root module for the gem
require 'cpt_hook'

# Top level module for the gem
module EDSL
  # rubocop:disable Metrics/AbcSize

  # Ensure the DSL methods are applied when we're included
  def self.included(cls)
    cls.extend EDSL::DSL

    add_resolvers(cls)

    cls.send(:define_method, :apply_hooks) do |hook_defs, element|
      return nil if element.nil?
      return element if hook_defs.nil?

      hd = hook_defs.dup
      hd.hooks.each { |hook| hook.call_chain.each { |cc| cc.resolve_with { |c| resolve_with(c) } } }
      hd.hooks.each { |hook| hook.call_chain.each { |cc| cc.resolve_contexts { |c| resolve_context(c) } } }
      CptHook::Hookable.new(element, hd, self)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def self.add_resolvers(cls)
    cls.send(:define_method, :resolve_with) do |with_var|
      return with_var.call if with_var.is_a?(Proc)
      return self if with_var == :parent
      return :self if with_var == :element

      with_var
    end

    cls.send(:define_method, :resolve_context) do |context|
      return context.call if context.is_a?(Proc)

      context
    end
  end

  # Use a block to add new methods to the DSL.
  def self.extend_dsl(&block)
    EDSL::DSL.class_eval(&block)
  end

  # Define a new accessor using a name and options.
  # See the DSL module for more info
  def self.define_accessor(acc_name, default_opts)
    DSL.define_accessor(acc_name, default_opts)
  end

  # Allow an accessor to be accessed by a different name
  def self.alias_accessor(new_name, acc_name)
    DSL.alias_accessor(new_name, acc_name)
  end

  # Allow multiple accessors to be defined at once
  def self.define_accessors(accessor_array)
    DSL.define_accessors(accessor_array)
  end

  # These methods will be extended into any class which includes EDSL.
  # They provide a mechanism for declaring HTML elements as properties of another object
  module DSL
    # This is the core accessor on which everything else is based.
    # Given a name and some options this will generate the following methods:
    #   name - Executes the method found in the :default_method option, or the element itself if none provided.
    #   name= - Executes the method found in the :assign_method option, passing it the value. (optional).
    #   name? - Executes the method found in the :presence_method option, or present?
    #
    # For example a text field would look like this:
    #   element(:username, id: 'some_id', how: :text_field, default_method: :value, assign_method: :set)
    #
    # The :how option can either be something that is sendable. or a proc
    #   If send is used, the options will be passed on to the method.
    #   If a proc is used it will be called with the name and opts param as well as the container
    #
    # A text field could be declared like this:
    #  element(:username, id: 'some_id', how: Proc.new { |name, container, opts| container.text_field(opts) }, default_method: :value, assign_method: :set)
    #
    def element(name, opts, &block)
      element_method = _add_element_method(name, opts, &block)
      _add_common_methods(name, element_method, opts)
      _add_assignment_methods(name, element_method, opts)
    end

    # Helper function to reduce perceived complexity of element
    def _add_assignment_methods(name, element_method, opts)
      assign_method = opts.delete(:assign_method)
      return unless assign_method

      define_method("#{name}=") do |value|
        return assign_method.call(name, self, value) if assign_method.is_a?(Proc)

        send(element_method).send(assign_method, value)
      end
    end

    # Helper function to reduce perceived complexity of element
    def _add_common_methods(name, element_method, opts)
      default_method = opts.delete(:default_method)
      presence_method = opts.delete(:presence_method) || :present?

      define_method(name) do
        return default_method.call(name, self) if default_method.is_a?(Proc)

        default_method.nil? ? send(element_method) : send(element_method).send(default_method)
      end

      define_method("#{name}?") do
        return presence_method.call(name, self) if presence_method.is_a?(Proc)

        send(element_method).send(presence_method)
      end
    end

    # rubocop:disable Metrics/AbcSize
    # Helper function to reduce perceived complexity of element
    def _add_element_method(name, opts, &block)
      how = opts.delete(:how)
      hooks = opts.delete(:hooks)
      wrapper_fn = opts.delete(:wrapper_fn) || ->(e, _p) { return e }

      ele_meth = "#{name}_element"
      define_method(ele_meth) do
        ele = yield self if block_given?
        ele ||= how.call(name, self, opts) if how.is_a?(Proc)
        ele ||= send(how, opts)
        ele = wrapper_fn.call(ele, self)
        hooks.nil? ? ele : send(:apply_hooks, hooks, ele)
      end
      ele_meth
    end
    # rubocop:enable Metrics/AbcSize

    # This vastly simplifies defining custom accessors.
    # If we had to use the base element method for every field that would be tedious.
    # This method allows us to extend the DSL to add a shorthand method for elements.
    #
    # If we extend the DSL like this:
    #   EDSL.define_accessor(:text_field, how: :text_field, default_method: :value, assign_method: :set)
    # Then we can use an easier syntax to declare a text field
    #   text_field(:username, id: 'some_id')
    #
    def self.define_accessor(acc_name, default_opts)
      self.class.send(:define_method, acc_name) do |name, opts = {}, &block|
        element(name, default_opts.merge(opts), &block)
      end
    end

    # Allow an accessor to be accessed by a different name
    def self.alias_accessor(new_name, acc_name)
      self.class.send(:alias_method, new_name, acc_name)
    end

    # Allow multiple accessors to be defined at once
    def self.define_accessors(accessor_array)
      accessor_array.each { |acc| define_accessor(*acc) }
    end
  end
end
