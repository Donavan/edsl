require 'facets/string/snakecase'

module EDSL
  # This module extends the DSL to include the various Watir elements
  module WatirElements
    SPECIAL_ELEMENTS = %i[button a radio_set input select textarea].freeze

    TEXT_ELEMENTS = Watir.tag_to_class.keys.reject { |k| SPECIAL_ELEMENTS.include?(k) }.map { |t| t.to_s.snakecase }.freeze
    TEXT_ELEMENTS.each do |tag|
      EDSL.define_accessor(tag, how: tag, default_method: :text)
    end

    CLICKABLE_ELEMENTS = %i[button a link].freeze
    CLICKABLE_ELEMENTS.each { |tag| EDSL.define_accessor(tag, how: tag, default_method: :click) }

    CONTENT_EDITABLE_ELEMENTS = %i[text_field textarea].freeze
    CONTENT_EDITABLE_ELEMENTS.each { |tag| EDSL.define_accessor(tag, how: tag, default_method: :value, assign_method: :set) }

    SETABLE_ELEMENTS = %i[radio checkbox].freeze
    SETABLE_ELEMENTS.each { |tag| EDSL.define_accessor(tag, how: tag, default_method: :set?, assign_method: :set) }
  end
end
