# frozen_string_literal: true

module CrewAI
  class Error < StandardError; end

  class ClientError < Error; end

  class AuthenticationError < ClientError; end

  class InvalidRequestError < ClientError; end

  class NotFoundError < ClientError; end

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
