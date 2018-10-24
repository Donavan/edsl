require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'edsl'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end


end

def watir_container_double
  container = instance_double('Watir::Container')
end

# This allows us to create unique classes for generating accessors in.
def unique_container_object(key, container)
  Object.const_set("EDSLSpecContainer#{key}", Class.new(EDSL::ElementContainer) { include EDSL }).new(container)
end

def watir_element_double
  ele = double('element')
  allow(ele).to receive(:set).with(anything)
  allow(ele).to receive(:set?).with(no_args).and_return(true)
  allow(ele).to receive(:value).with(no_args)
  allow(ele).to receive(:click).with(no_args)
  allow(ele).to receive(:text).with(no_args).and_return('text')
  allow(ele).to receive(:href).with(no_args).and_return('href')
  ele
end