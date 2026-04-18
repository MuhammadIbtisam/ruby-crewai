# frozen_string_literal: true

RSpec.describe CrewAI::HTTP do
  let(:config) { CrewAI::Configuration.new.tap { |c| c.access_token = "test-token" } }

  describe "uri_base validation" do
    context "when uri_base is nil" do
      it "raises ArgumentError on the first request" do
        http = described_class.new(configuration: config)
        expect { http.get("/inputs") }.to raise_error(ArgumentError, /uri_base/)
      end
    end

    context "when uri_base is blank" do
      it "raises ArgumentError on the first request" do
        config.uri_base = "   "
        http = described_class.new(configuration: config)
        expect { http.get("/inputs") }.to raise_error(ArgumentError, /uri_base/)
      end
    end

    context "when uri_base is set" do
      before { stub_request(:get, "https://example.crewai.com/inputs").to_return(status: 200, body: "{}") }

      it "makes the request without error" do
        config.uri_base = "https://example.crewai.com"
        http = described_class.new(configuration: config)
        expect { http.get("/inputs") }.not_to raise_error
      end
    end
  end
end
