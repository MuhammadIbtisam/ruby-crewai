# frozen_string_literal: true

module CrewAI
  class Client
    CONFIG_KEYS = %i[access_token uri_base open_timeout read_timeout write_timeout].freeze
    attr_reader(*CONFIG_KEYS)

    def initialize(config = {})
      CONFIG_KEYS.each do |key|
        instance_variable_set(
          "@#{key}",
          config[key].nil? ? CrewAI.configuration.send(key) : config[key]
        )
      end
    end

    def inputs
      http.get("/inputs")
    end

    private

    def http
      @http ||= HTTP.new(self)
    end
  end
end
