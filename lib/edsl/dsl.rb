# Root module for the gem
module EDSL
  # Ensure the DSL methods are applied when we're included
  def self.included(cls)
    cls.extend EDSL::DSL
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
    def element(name, opts)
      how = opts.delete(:how)
      default_method = opts.delete(:default_method)
      assign_method = opts.delete(:assign_method)
      presence_method = opts.delete(:presence_method) || :present?

      ele_meth = "#{name}_element"
      define_method(ele_meth) do
        ele = yield name, self, opts if block_given?
        ele ||= how.call(name, self, opts) if how.is_a?(Proc)
        ele ||= send(how, opts)
        ele
      end

      define_method(name) do
        default_method.nil? ? send(ele_meth) : send(ele_meth).send(default_method)
      end

      define_method("#{name}?") do
        send(ele_meth).send(presence_method)
      end

      return unless assign_method

      define_method("#{name}=") do |value|
        send(ele_meth).send(assign_method, value)
      end
    end

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

    def self.alias_accessor(new_name, acc_name)
      self.class.send(:alias_method, new_name, acc_name)
    end

    def self.define_accessors(accessor_array)
      accessor_array.each do |acc|
        define_accessor(*acc)
      end
    end
  end
end
