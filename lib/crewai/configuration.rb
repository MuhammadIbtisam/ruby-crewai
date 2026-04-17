# frozen_string_literal: true

module CrewAI
  class Configuration
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 30
    DEFAULT_WRITE_TIMEOUT = 30

    attr_accessor :access_token,
                  :uri_base,
                  :open_timeout,
                  :read_timeout,
                  :write_timeout

    def initialize
      @open_timeout = DEFAULT_OPEN_TIMEOUT
      @read_timeout = DEFAULT_READ_TIMEOUT
      @write_timeout = DEFAULT_WRITE_TIMEOUT
    end
  end
end
