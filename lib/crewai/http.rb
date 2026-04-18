# frozen_string_literal: true

require "faraday"

module CrewAI
  class HTTP
    USER_AGENT = "ruby-crewai/#{VERSION} Ruby/#{RUBY_VERSION}".freeze

    def initialize(configuration:)
      @configuration = configuration
    end

    def get(path)
      request(:get, path, body: nil)
    end

    def post(path, body)
      request(:post, path, body: body)
    end

    private

    attr_reader :configuration

    def request(method, path, body:)
      connection.public_send(method, path) do |req|
        req.headers["Authorization"] = "Bearer #{configuration.access_token}" if configuration.access_token
        req.headers["User-Agent"] = USER_AGENT
        req.body = body if body
      end
    rescue Faraday::TimeoutError => e
      raise CrewAI::TimeoutError, e.message
    rescue Faraday::ConnectionFailed, Faraday::SSLError => e
      raise CrewAI::ConnectionError, e.message
    end

    def connection
      @connection ||= Faraday.new(url: normalized_base_url) do |f|
        f.options.open_timeout = configuration.open_timeout
        f.options.timeout = configuration.read_timeout
        f.options.write_timeout = configuration.write_timeout if f.options.respond_to?(:write_timeout=)
        f.request :json
        f.response :json, content_type: /\bjson\b/
        f.adapter Faraday.default_adapter
      end
    end

    def normalized_base_url
      base = configuration.uri_base.to_s.strip
      raise ArgumentError, "CrewAI uri_base must be set (e.g. https://your-crew.crewai.com)" if base.empty?

      base.chomp("/")
    end
  end
end
