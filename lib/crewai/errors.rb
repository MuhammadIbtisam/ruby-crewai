# frozen_string_literal: true

module CrewAI
  class Error < StandardError; end

  class HTTPError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      super(message)
      @status = status
      @body = body
    end
  end

  class AuthenticationError < HTTPError; end

  class InvalidRequestError < HTTPError; end

  class NotFoundError < HTTPError; end

  class ServerError < HTTPError; end

  class TimeoutError < Error; end

  class ConnectionError < Error; end
end
