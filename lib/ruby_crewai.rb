# frozen_string_literal: true

require_relative "crewai/version"
require_relative "crewai/configuration"
require_relative "crewai/errors"

module CrewAI
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
