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

  describe "4xx errors are rescuable as CrewAI::ClientError" do
    {
      "401" => [401, "Unauthorized", CrewAI::AuthenticationError],
      "422" => [422, "Bad input", CrewAI::InvalidRequestError],
      "404" => [404, "Not found", CrewAI::NotFoundError]
    }.each do |label, (status, message, klass)|
      context "when the server returns #{label} (#{klass})" do
        before do
          stub_request(:get, "#{uri_base}/healthcheck")
            .to_return(
              status: status,
              body: { "message" => message }.to_json,
              headers: { "Content-Type" => "application/json" }
            )
        end

        it "raises #{klass}" do
          expect { client.healthcheck }.to raise_error(klass)
        end

        it "is rescuable as CrewAI::ClientError" do
          expect { client.healthcheck }.to raise_error(CrewAI::ClientError)
        end

        it "is rescuable as CrewAI::Error" do
          expect { client.healthcheck }.to raise_error(CrewAI::Error)
        end
      end
    end
  end

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

    context "when an SSL error occurs" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_raise(Faraday::SSLError.new("SSL certificate verify failed"))
      end

      it "raises CrewAI::ConnectionError" do
        expect { client.healthcheck }.to raise_error(CrewAI::ConnectionError, /SSL certificate verify failed/)
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
