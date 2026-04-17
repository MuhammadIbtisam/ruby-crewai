# frozen_string_literal: true

require "faraday"

module CrewAI
  class HTTP
    def initialize(config = CrewAI.configuration)
      @access_token = config.access_token
      @uri_base = config.uri_base
      @open_timeout = config.open_timeout
      @read_timeout = config.read_timeout
      @write_timeout = config.write_timeout
      validate_uri_base!
    end

    def get(path)
      response = connection.get(path)
      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise CrewAI::TimeoutError, e.message
    rescue Faraday::ConnectionFailed => e
      raise CrewAI::ConnectionError, e.message
    end

    def post(path, body = {})
      response = connection.post(path) { |req| req.body = body }
      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise CrewAI::TimeoutError, e.message
    rescue Faraday::ConnectionFailed => e
      raise CrewAI::ConnectionError, e.message
    end

    private

    def connection
      @connection ||= Faraday.new(url: @uri_base) do |conn|
        conn.headers["Authorization"] = "Bearer #{@access_token}"
        conn.headers["Content-Type"] = "application/json"
        conn.headers["User-Agent"] = "ruby-crewai/#{CrewAI::VERSION}"
        conn.options.open_timeout = @open_timeout
        conn.options.timeout = @read_timeout
        conn.options.write_timeout = @write_timeout
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      body = parse(response.body)
      raise_for_status!(response.status, body)
      body
    end

    def parse(body)
      case body
      when Hash then body
      when nil then {}
      else {}
      end
    end

    def raise_for_status!(status, body)
      message = error_message(body)
      case status
      when 401 then raise AuthenticationError.new(message, status: status, body: body)
      when 400, 422 then raise InvalidRequestError.new(message, status: status, body: body)
      when 404 then raise NotFoundError.new(message, status: status, body: body)
      when 500..599 then raise ServerError.new(message, status: status, body: body)
      end
    end

    def error_message(body)
      return "Unknown error" unless body.is_a?(Hash)

      body.dig("error", "message") || body["message"] || body["detail"] || "Unknown error"
    end

    def validate_uri_base!
      return if @uri_base && !@uri_base.to_s.strip.empty?

      raise CrewAI::Error, "uri_base must be configured, set it via CrewAI.configure or pass it to Client.new"
    end
  end
end
