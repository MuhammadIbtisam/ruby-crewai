# frozen_string_literal: true

module CrewAI
  class Client
    def initialize(access_token: nil, uri_base: nil, configuration: nil)
      @configuration = configuration || CrewAI.configuration.dup
      @configuration.access_token = access_token if access_token
      @configuration.uri_base = uri_base if uri_base
      @http = HTTP.new(configuration: @configuration)
    end

    def inputs
      parse(@http.get("/inputs"))
    end

    def kickoff(inputs:, meta: nil, task_webhook_url: nil, step_webhook_url: nil, crew_webhook_url: nil)
      body = { "inputs" => stringify_keys(inputs) }
      body["meta"] = stringify_keys(meta) if meta
      body["taskWebhookUrl"] = task_webhook_url if task_webhook_url
      body["stepWebhookUrl"] = step_webhook_url if step_webhook_url
      body["crewWebhookUrl"] = crew_webhook_url if crew_webhook_url
      parse(@http.post("/kickoff", body))
    end

    private

    def parse(response)
      raise_for_status!(response)
      return {} if response.body.nil?

      response.body.is_a?(Hash) ? response.body : {}
    end

    def raise_for_status!(response)
      return if response.success?

      case response.status
      when 401 then raise AuthenticationError, error_message(response)
      when 400, 422 then raise InvalidRequestError, error_message(response)
      when 404 then raise NotFoundError, error_message(response)
      when 500..599 then raise ServerError, error_message(response)
      else raise HTTPError.new(error_message(response), status: response.status, body: response.body)
      end
    end

    def error_message(response)
      body = response.body
      return body.to_s unless body.is_a?(Hash)

      body["message"] || body["error"] || body.to_json
    end

    def stringify_keys(hash)
      hash.to_h.transform_keys(&:to_s)
    end
  end
end
