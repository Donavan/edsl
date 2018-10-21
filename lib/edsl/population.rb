require 'facets/string'

module EDSL
  # This module serves as a mixin for element container to support populating their
  # fields via a hash.
  module Population

    # This method allows you to specify a function to be used to fetch fixture data,
    # given a key.  The value passed should either be a proc, or a method name for send.
    #
    # Examples:  EDSL::Population.fixture_fetch= :data_for
    #
    #            EDSL::Population.fixture_fetch= lambda.new { |key| data_for key }
    #
    # Both of these examples would call data_for from DataMagic
    #
    # @param proc_or_name [Proc, String, Symbol] A Proc to call or the name of a method to send.
    def self.fixture_fetcher=(proc_or_name)
      @@fixture_fetcher = proc_or_name
    end

    # Returns the currently defined fixture fetch function or a lambda that returns nil
    def self.fixture_fetcher
      @@fixture_fetcher = lambda.new { |_key| nil }
    end

    # Fetch a value from our fixtures using a key.
    #
    # @param key [String, Symbol] What to fetch
    def fixture_fetch(key)
      ff = fixture_fetcher
      return ff.call(key) if ff.is_a?(Proc)
      send(ff, key)
    end

    # This method will populate the various elements within a container, using a hash.
    #
    # If the hash contains a key that matches the #populate_key of the container, the
    # value contained there will be used instead of the passed hash. Otherwise, the
    # data will be used directly.
    #
    # For each key in the hash, this method will call send("#{key}=") passing it the value
    # from the hash (if we respond to that message).
    #
    # This function makes no attempt to determine the type of element being set,
    # it assumes that what ever you put in the value can be consumed by the assignment function.
    #
    # Values are populated in the order they appear in the hash.
    #
    #
    # @param data [Hash] the data to use to populate this container.  The key
    # can be either a string or a symbol.
    def populate_with(data)
      data = data.fetch(populate_key, data)
      data = data.fetch(populate_key.to_sym, data)
      data.each do  |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    # This method will provide a value that can be used as a key for selecting data out of a hash
    # for a specific container.  It uses the class name of the object and converts it into snake case
    # so LoginPage would have a populate key of login_page.
    def populate_key
      self.class.to_s.snakecase
    end
  end
end