# frozen_string_literal: true

RSpec.describe CrewAI::Client do
  let(:configuration) do
    CrewAI::Configuration.new.tap do |c|
      c.access_token = "test-token"
      c.uri_base = "https://test.crewai.com"
    end
  end
  let(:client) { described_class.new(configuration: configuration) }
  let(:uri_base) { "https://test.crewai.com" }

  describe "transport errors" do
    context "when the request times out" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_raise(Faraday::TimeoutError.new("timed out"))
      end

      it "raises CrewAI::TimeoutError" do
        expect { client.healthcheck }.to raise_error(CrewAI::TimeoutError)
      end
    end

    context "when the connection fails" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_raise(Faraday::ConnectionFailed.new("connection refused"))
      end

      it "raises CrewAI::ConnectionError" do
        expect { client.healthcheck }.to raise_error(CrewAI::ConnectionError, /connection refused/)
      end
    end
  end

  describe "unexpected HTTP status (catch-all)" do
    context "when the server returns 429 Too Many Requests" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_return(
            status: 429,
            body: { "message" => "rate limit exceeded" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::HTTPError" do
        expect { client.healthcheck }.to raise_error(CrewAI::HTTPError)
      end

      it "exposes the HTTP status on the exception" do
        client.healthcheck
      rescue CrewAI::HTTPError => e
        expect(e.status).to eq(429)
      end

      it "exposes the parsed body on the exception" do
        client.healthcheck
      rescue CrewAI::HTTPError => e
        expect(e.body).to eq({ "message" => "rate limit exceeded" })
      end

      it "includes the server message in the exception message" do
        expect { client.healthcheck }.to raise_error(CrewAI::HTTPError, /rate limit exceeded/)
      end
    end
  end
end
