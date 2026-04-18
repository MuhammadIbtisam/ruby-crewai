# frozen_string_literal: true

module CrewAI
  class Error < StandardError; end

  class AuthenticationError < Error; end

  class InvalidRequestError < Error; end

  class NotFoundError < Error; end

  class ServerError < Error; end

  class TimeoutError < Error; end

  class ConnectionError < Error; end

  class HTTPError < Error
    attr_reader :status, :body

    def initialize(message, status:, body:)
      super(message)
      @status = status
      @body = body
    end
  end
end
