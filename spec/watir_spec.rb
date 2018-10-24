RSpec.describe 'EDSL::WatirElements' do
  EDSL::WatirElements::TEXT_ELEMENTS.each do |tag|
    it "defines an accessor for #{tag} that calls text as the default method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:text)
      expect(container.test_element).to eq('text')
    end
  end

  EDSL::WatirElements::CLICKABLE_ELEMENTS.each do |tag|
    it "defines an accessor for #{tag} that calls click as the default method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:click)
      container.test_element
    end
  end

  EDSL::WatirElements::CONTENT_EDITABLE_ELEMENTS.each do |tag|
    it "defines an accessor for #{tag} that calls value as the default method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:value)
      expect(container.test_element).to eq('value')
    end

    it "defines an accessor for #{tag} that calls set as the assignment method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}_set", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:set).with('value')
      container.test_element = 'value'
    end
  end

  EDSL::WatirElements::SETABLE_ELEMENTS.each do |tag|
    it "defines an accessor for #{tag} that calls set? as the default method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:set?)
      expect(container.test_element).to eq(true)
    end

    it "defines an accessor for #{tag} that calls set as the assignment method" do
      container_double = watir_container_double
      element_double = watir_element_double

      allow(container_double).to receive(tag).with(any_args).and_return(element_double)

      container = unique_container_object("Watir#{tag}_set", container_double)
      container.class.send(tag, :test_element, id: 'foo')

      expect(element_double).to receive(:set).with(false)
      container.test_element = false
    end
  end

end
