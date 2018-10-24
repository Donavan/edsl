RSpec.describe 'element DSL' do
  it 'creates a default method' do
    container_double = watir_container_double
    container = unique_container_object(:default_method, container_double)
    container.class.send(:element, :test_ele, how: :div, id: 'foo')
    expect(container).to respond_to(:test_ele)
  end

  it 'defines a method to return the element' do
    container_double = watir_container_double
    container = unique_container_object(:element_method, container_double)
    container.class.send(:element, :test_link, how: :link, id: 'foo')
    expect(container).to respond_to(:test_link_element)
  end

  it 'creates a method to determine is an element is present' do
    container_double = watir_container_double
    container = unique_container_object(:presence_method, container_double)
    container.class.send(:element, :test_ele, how: :div, id: 'foo')
    expect(container).to respond_to(:test_ele?)
  end

  it 'returns the element using the appropriate method when accessing the element' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:link).with(any_args).and_return(element_double)
    container = unique_container_object(:use_element_method, container_double)
    container.class.send(:element, :test_link, how: :link, id: 'foo')
    expect(container_double).to receive(:link).with(id: 'foo')
    expect(container.test_link_element).to eq(element_double)
  end

  it 'returns the element if no default method is specified' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:link).with(any_args).and_return(element_double)
    container = unique_container_object(:no_default_method, container_double)
    container.class.send(:element, :test_link, how: :link, id: 'foo')
    expect(container.test_link).to eq(element_double)
  end

  it 'allows the default method to be specified' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:specify_default_method, container_double)
    container.class.send(:element, :test_div, default_method: :text, how: :div, id: 'foo')
    expect(element_double).to receive(:text)
    expect(container.test_div).to eq('text')
  end

  it 'allows the presence method to be specified' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:specify_presence_method, container_double)
    container.class.send(:element, :test_div, presence_method: :is_here?, how: :div, id: 'foo')
    allow(element_double).to receive(:is_here?).with(no_args).and_return(true)
    expect(container.test_div?).to eq(true)
  end

  it 'can create assignment methods' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:specify_assign_method, container_double)
    container.class.send(:element, :test_div, assign_method: :set, how: :div, id: 'foo')
    expect(element_double).to receive(:set).with('test')
    container.test_div = 'test'
  end

  it 'allows elements to be wrapped in a decorator via :wrapper_fn' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:decorators, container_double)
    wrapper_fn = ->(ele, cont) { EDSL::ElementContainer.new(ele, cont) }
    container.class.send(:element, :test_div, how: :div, wrapper_fn: wrapper_fn, id: 'foo')
    expect(container.test_div).to be_an(EDSL::ElementContainer)
  end

  it 'can call a proc for :how' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:how_as_proc, container_double)
    how_proc = ->(_name, cont, opts) { cont.div(opts) }
    container.class.send(:element, :test_div, how: how_proc, id: 'foo')
    expect(container_double).to receive(:div).with(id: 'foo')
    expect(container.test_div).to eq(element_double)
  end

  it 'can call a proc for :default_method' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(element_double).to receive(:default_method).with(no_args).and_return('default')
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:default_as_proc, container_double)
    default_method = ->(name, cont) { cont.send("#{name}_element").default_method }
    container.class.send(:element, :test_div, default_method: default_method, how: :div, id: 'foo')
    expect(element_double).to receive(:default_method)
    expect(container.test_div).to eq('default')
  end

  it 'can call a proc for :assign_method' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:assign_as_proc, container_double)
    assign_proc = ->(name, cont, value) { cont.send("#{name}_element").set(value) }
    container.class.send(:element, :test_div, assign_method: assign_proc, how: :div, id: 'foo')
    expect(element_double).to receive(:set).with('test')
    container.test_div = 'test'
  end

  it 'can call a proc for :presence_method' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:presence_as_proc, container_double)
    presence_method = ->(name, cont) { cont.send("#{name}_element").present? }
    container.class.send(:element, :test_div, presence_method: presence_method, how: :div, id: 'foo')
    expect(element_double).to receive(:present?)
    container.test_div?
  end

  it 'will wrap elements with a CptHook::Hookable if hooks are provided' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:hooks, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn)
    end
    container.class.send(:element, :test_div, hooks: hooks, how: :div, id: 'foo')
    expect(container.test_div).to respond_to(:before_text)
  end

  it 'will resolve methods on the element via hooks' do
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(element_double).to receive(:some_fn)
    container = unique_container_object(:hook_resolve_element, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(element_double).to receive(:some_fn)
    container.test_div
  end

  it 'will resolve methods on the container via hooks' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(container_double).to receive(:some_fn)
    container = unique_container_object(:hook_resolve_container, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(container_double).to receive(:some_fn)
    container.test_div
  end

  it 'will allows procs and contexts for hooks' do
    container_double = instance_double('container')
    other_double = double('dummy_object')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(other_double).to receive(:some_fn)
    container = unique_container_object(:hook_proc_context_container, container_double)
    context_proc = -> { return other_double }
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).using(context_proc)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(other_double).to receive(:some_fn)
    container.test_div
  end

  it 'will allows arbitrary objects as contexts for hooks' do
    container_double = instance_double('container')
    other_double = double('dummy_object')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(other_double).to receive(:some_fn)
    container = unique_container_object(:hook_obj_context_container, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).using(other_double)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(other_double).to receive(:some_fn)
    container.test_div
  end

  it 'can pass the element as an argument to a hook function' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(container_double).to receive(:some_fn).with(any_args)
    container = unique_container_object(:hook_element_as_arg, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).with(:element)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(container_double).to receive(:some_fn).with(element_double)
    container.test_div
  end

  it 'can pass the container as an argument to a hook function' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(container_double).to receive(:some_fn).with(any_args)
    container = unique_container_object(:hook_parent_as_arg, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).with(:parent)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(container_double).to receive(:some_fn).with(container)
    container.test_div
  end

  it 'can pass arbitrary values to a hook function' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(container_double).to receive(:some_fn).with(any_args)
    container = unique_container_object(:hook_arb_arg, container_double)
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).with(42)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(container_double).to receive(:some_fn).with(42)
    container.test_div
  end

  it 'can pass the return value of a proc to a hook function' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(container_double).to receive(:some_fn).with(any_args)
    container = unique_container_object(:hook_proc_arg, container_double)
    value_proc = -> { return 42 }
    hooks = CptHook.define_hooks do
      before(:text).call(:some_fn).with(value_proc)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(container_double).to receive(:some_fn).with(42)
    container.test_div
  end

  it 'can call a proc as a hook function' do
    container_double = instance_double('container')
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    allow(element_double).to receive(:some_fn).with(any_args)
    container = unique_container_object(:hook_proc_hook, container_double)
    call_proc = ->(ele) { ele.some_fn(42) }
    hooks = CptHook.define_hooks do
      before(:text).call(call_proc).with(:element)
    end
    container.class.send(:element, :test_div, hooks: hooks, default_method: :text, how: :div, id: 'foo')
    expect(element_double).to receive(:some_fn).with(42)
    container.test_div
  end
end
