RSpec.describe 'EDSL::DSL' do
  it 'can be extended with define_accessor' do
    EDSL.define_accessor(:spec_1, how: :div)
    expect(EDSL::DSL).to respond_to(:spec_1)
  end

  it 'can be extended with extend_dsl' do
    EDSL.extend_dsl do
      def spec_2
      end
    end
    expect(EDSL::DSL.instance_methods).to include(:spec_2)
  end

  it 'allows accessors to have aliases' do
    EDSL.define_accessor(:spec_3, how: :div)
    EDSL.alias_accessor(:spec_4, :spec_3)
    expect(EDSL::DSL).to respond_to(:spec_4)
  end

  it 'allows bulk creation of accessors' do
    accessors = [[:spec_5, how: :div], [:spec_6, how: :div]]
    EDSL.define_accessors(accessors)

    expect(EDSL::DSL).to respond_to(:spec_5)
    expect(EDSL::DSL).to respond_to(:spec_6)
  end

  it 'creates the correct methods when defined accessors are used' do
    EDSL.define_accessor(:spec_7, how: :div)
    container = unique_container_object(:custom_acc_def, watir_container_double)
    container.class.send(:spec_7, :test_element, id: 'foo')
    expect(container).to respond_to(:test_element)
    expect(container).to respond_to(:test_element?)
  end

  it 'defined accessors call element with default options' do
    EDSL.define_accessor(:spec_8, how: :div)
    container_double = watir_container_double
    element_double = watir_element_double
    allow(container_double).to receive(:div).with(any_args).and_return(element_double)
    container = unique_container_object(:custom_acc_def, container_double)
    container.class.send(:spec_8, :test_element2, id: 'foo')
    expect(container).to receive(:div).with(id: 'foo')
    expect(container).to respond_to(:test_element2)

    container.test_element2
  end

end