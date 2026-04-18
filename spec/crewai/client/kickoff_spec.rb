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
  let(:kickoff_response) { { "kickoff_id" => "abc-123" } }

  describe "#kickoff" do
    context "when successful (200)" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns a hash containing the kickoff_id" do
        expect(client.kickoff(inputs: { "topic" => "AI" })).to eq(kickoff_response)
      end
    end

    context "when server responds with 201 Created" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 201,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "treats 201 as success and returns the response" do
        expect(client.kickoff(inputs: { "topic" => "AI" })).to eq(kickoff_response)
      end
    end

    context "when inputs have string keys" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .with(body: hash_including("inputs" => { "topic" => "AI" }))
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "passes string keys through unchanged" do
        expect(client.kickoff(inputs: { "topic" => "AI" })).to eq(kickoff_response)
      end
    end

    context "when inputs have symbol keys" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .with(body: hash_including("inputs" => { "topic" => "AI" }))
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "converts symbol keys to strings" do
        expect(client.kickoff(inputs: { topic: "AI" })).to eq(kickoff_response)
      end
    end

    context "when webhook URLs are provided" do
      let(:webhook_url) { "https://example.com/webhook" }

      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .with(
            body: hash_including(
              "taskWebhookUrl" => webhook_url,
              "stepWebhookUrl" => webhook_url,
              "crewWebhookUrl" => webhook_url
            )
          )
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "serialises webhook URLs as camelCase JSON keys" do
        expect(
          client.kickoff(
            inputs: { "topic" => "AI" },
            task_webhook_url: webhook_url,
            step_webhook_url: webhook_url,
            crew_webhook_url: webhook_url
          )
        ).to eq(kickoff_response)
      end
    end

    context "when webhook URLs are omitted" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "does not include any webhook keys in the request body" do
        client.kickoff(inputs: { "topic" => "AI" })

        %w[taskWebhookUrl stepWebhookUrl crewWebhookUrl].each do |key|
          expect(
            a_request(:post, "#{uri_base}/kickoff")
              .with { |req| JSON.parse(req.body).key?(key) }
          ).not_to have_been_made
        end
      end
    end

    context "when meta is provided" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .with(body: hash_including("meta" => { "source" => "test" }))
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "includes meta with stringified keys in the request body" do
        expect(client.kickoff(inputs: { "topic" => "AI" }, meta: { source: "test" })).to eq(kickoff_response)
      end
    end

    context "when meta is omitted" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 200,
            body: kickoff_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "does not include meta in the request body" do
        client.kickoff(inputs: { "topic" => "AI" })

        expect(
          a_request(:post, "#{uri_base}/kickoff")
            .with { |req| JSON.parse(req.body).key?("meta") }
        ).not_to have_been_made
      end
    end

    context "when the server returns 422 (missing inputs)" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 422,
            body: { "message" => "inputs are required" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::InvalidRequestError with the server message" do
        expect { client.kickoff(inputs: {}) }.to raise_error(CrewAI::InvalidRequestError, /inputs are required/)
      end
    end

    context "when unauthorized" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 401,
            body: { "message" => "Unauthorized" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::AuthenticationError with the server message" do
        expect { client.kickoff(inputs: { "topic" => "AI" }) }.to raise_error(CrewAI::AuthenticationError, /Unauthorized/)
      end
    end

    context "when server error" do
      before do
        stub_request(:post, "#{uri_base}/kickoff")
          .to_return(
            status: 500,
            body: { "message" => "Internal Server Error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::ServerError" do
        expect { client.kickoff(inputs: { "topic" => "AI" }) }.to raise_error(CrewAI::ServerError)
      end
    end
  end
end
