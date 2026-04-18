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

  describe "#inputs" do
    context "when successful" do
      before do
        stub_request(:get, "#{uri_base}/inputs")
          .to_return(
            status: 200,
            body: { "inputs" => %w[topic audience] }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns a hash with the required input keys" do
        expect(client.inputs).to eq({ "inputs" => %w[topic audience] })
      end
    end

    context "when unauthorized" do
      before do
        stub_request(:get, "#{uri_base}/inputs")
          .to_return(
            status: 401,
            body: { "message" => "Unauthorized" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::AuthenticationError with the server message" do
        expect { client.inputs }.to raise_error(CrewAI::AuthenticationError, /Unauthorized/)
      end
    end

    context "when server error" do
      before do
        stub_request(:get, "#{uri_base}/inputs")
          .to_return(
            status: 500,
            body: { "message" => "Internal Server Error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::ServerError" do
        expect { client.inputs }.to raise_error(CrewAI::ServerError)
      end
    end
  end
end
