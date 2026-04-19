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
  let(:kickoff_id) { "k-abc-123" }

  describe "#status" do
    context "when successful" do
      before do
        stub_request(:get, "#{uri_base}/status/#{kickoff_id}")
          .to_return(
            status: 200,
            body: { "status" => "running" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns a hash with the status" do
        expect(client.status(kickoff_id)).to eq({ "status" => "running" })
      end

      it "GETs the correct path" do
        client.status(kickoff_id)
        expect(a_request(:get, "#{uri_base}/status/#{kickoff_id}")).to have_been_made.once
      end
    end

    context "when the kickoff_id is not found (404)" do
      before do
        stub_request(:get, "#{uri_base}/status/#{kickoff_id}")
          .to_return(
            status: 404,
            body: { "message" => "Kickoff not found" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::NotFoundError" do
        expect { client.status(kickoff_id) }.to raise_error(CrewAI::NotFoundError)
      end

      it "includes the server message" do
        expect { client.status(kickoff_id) }.to raise_error(CrewAI::NotFoundError, /Kickoff not found/)
      end
    end

    context "when unauthorized" do
      before do
        stub_request(:get, "#{uri_base}/status/#{kickoff_id}")
          .to_return(
            status: 401,
            body: { "message" => "Unauthorized" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::AuthenticationError with the server message" do
        expect { client.status(kickoff_id) }.to raise_error(CrewAI::AuthenticationError, /Unauthorized/)
      end
    end

    context "when server error" do
      before do
        stub_request(:get, "#{uri_base}/status/#{kickoff_id}")
          .to_return(
            status: 500,
            body: { "message" => "Internal Server Error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::ServerError" do
        expect { client.status(kickoff_id) }.to raise_error(CrewAI::ServerError)
      end
    end
  end
end
