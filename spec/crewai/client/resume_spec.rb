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
  let(:resume_params) do
    { execution_id: "e-1", task_id: "t-1", human_feedback: "looks good", is_approve: true }
  end

  describe "#resume" do
    context "when successful" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .to_return(
            status: 200,
            body: { "status" => "resumed" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns a hash with the status" do
        expect(client.resume(**resume_params)).to eq({ "status" => "resumed" })
      end

      it "POSTs with camelCase executionId and taskId" do
        client.resume(**resume_params)
        expect(
          a_request(:post, "#{uri_base}/resume").with(
            body: hash_including(
              "executionId" => "e-1",
              "taskId" => "t-1",
              "human_feedback" => "looks good",
              "is_approve" => true
            )
          )
        ).to have_been_made.once
      end
    end

    context "when is_approve is false" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .with(body: hash_including("is_approve" => false))
          .to_return(
            status: 200,
            body: { "status" => "resumed" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "sends is_approve: false in the request body" do
        expect(client.resume(**resume_params, is_approve: false)).to eq({ "status" => "resumed" })
      end
    end

    context "when webhook URLs are provided" do
      let(:webhook_url) { "https://example.com/webhook" }

      before do
        stub_request(:post, "#{uri_base}/resume")
          .with(
            body: hash_including(
              "taskWebhookUrl" => webhook_url,
              "stepWebhookUrl" => webhook_url,
              "crewWebhookUrl" => webhook_url
            )
          )
          .to_return(
            status: 200,
            body: { "status" => "resumed" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "serialises webhook URLs as camelCase JSON keys" do
        expect(
          client.resume(
            **resume_params,
            task_webhook_url: webhook_url,
            step_webhook_url: webhook_url,
            crew_webhook_url: webhook_url
          )
        ).to eq({ "status" => "resumed" })
      end
    end

    context "when webhook URLs are omitted" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .to_return(
            status: 200,
            body: { "status" => "resumed" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "does not include any webhook keys in the request body" do
        client.resume(**resume_params)

        %w[taskWebhookUrl stepWebhookUrl crewWebhookUrl].each do |key|
          expect(
            a_request(:post, "#{uri_base}/resume")
              .with { |req| JSON.parse(req.body).key?(key) }
          ).not_to have_been_made
        end
      end
    end

    context "when the server returns 422 (missing required fields)" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .to_return(
            status: 422,
            body: { "message" => "execution_id is required" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::InvalidRequestError with the server message" do
        expect do
          client.resume(**resume_params)
        end.to raise_error(CrewAI::InvalidRequestError, /execution_id is required/)
      end
    end

    context "when unauthorized" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .to_return(
            status: 401,
            body: { "message" => "Unauthorized" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::AuthenticationError with the server message" do
        expect { client.resume(**resume_params) }.to raise_error(CrewAI::AuthenticationError, /Unauthorized/)
      end
    end

    context "when server error" do
      before do
        stub_request(:post, "#{uri_base}/resume")
          .to_return(
            status: 500,
            body: { "message" => "Internal Server Error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "raises CrewAI::ServerError" do
        expect { client.resume(**resume_params) }.to raise_error(CrewAI::ServerError)
      end
    end
  end
end
