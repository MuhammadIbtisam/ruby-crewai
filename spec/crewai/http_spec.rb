# frozen_string_literal: true

RSpec.describe CrewAI::HTTP do
  def config_with(uri_base:, access_token: "test-token")
    CrewAI::Configuration.new.tap do |c|
      c.access_token = access_token
      c.uri_base = uri_base
    end
  end

  describe "#initialize" do
    context "when uri_base is nil" do
      it "raises CrewAI::Error" do
        expect { described_class.new(config_with(uri_base: nil)) }
          .to raise_error(CrewAI::Error, /uri_base must be configured/)
      end
    end

    context "when uri_base is blank" do
      it "raises CrewAI::Error" do
        expect { described_class.new(config_with(uri_base: "   ")) }
          .to raise_error(CrewAI::Error, /uri_base must be configured/)
      end
    end

    context "when uri_base is set" do
      it "instantiates without error" do
        expect { described_class.new(config_with(uri_base: "https://example.crewai.com")) }
          .not_to raise_error
      end
    end
  end
end
