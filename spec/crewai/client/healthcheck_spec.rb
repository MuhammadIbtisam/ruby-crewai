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

  describe "#healthcheck" do
    context "when healthy" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_return(
            status: 200,
            body: { "status" => "healthy", "version" => "1.13.0" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns a hash with status healthy" do
        expect(client.healthcheck).to eq({ "status" => "healthy", "version" => "1.13.0" })
      end

      it "GETs /healthcheck" do
        client.healthcheck
        expect(a_request(:get, "#{uri_base}/healthcheck")).to have_been_made.once
      end
    end

    context "when unauthorized" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_return(
            status: 401,
            body: { "message" => "Unauthorized" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::AuthenticationError" do
        expect { client.healthcheck }.to raise_error(CrewAI::AuthenticationError, /Unauthorized/)
      end
    end

    context "when server error" do
      before do
        stub_request(:get, "#{uri_base}/healthcheck")
          .to_return(
            status: 500,
            body: { "message" => "Internal Server Error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::ServerError" do
        expect { client.healthcheck }.to raise_error(CrewAI::ServerError)
      end
    end
  end
end
