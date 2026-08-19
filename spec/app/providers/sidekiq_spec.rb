# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Providers::Sidekiq do
  subject :provider do
    described_class.new provider_container:,
                        target_container:,
                        slice:,
                        resolver: proc { sidekiq },
                        schedule:,
                        extension_repository:
  end

  let(:provider_container) { Dry::Core::Container.new }
  let(:target_container) { Dry::Core::Container.new }
  let(:slice) { Hanami.app }
  let(:sidekiq) { class_spy Sidekiq }
  let(:schedule) { instance_spy Terminus::Aspects::Jobs::Schedule }
  let(:extension_repository) { instance_spy Terminus::Repositories::Extension }

  describe "#prepare" do
    it "answers false due to already being loaded" do
      expect(provider.prepare).to be(false)
    end
  end

  describe "#start" do
    it "configures server" do
      provider.start
      expect(sidekiq).to have_received(:configure_server)
    end

    it "configures client" do
      provider.start
      expect(sidekiq).to have_received(:configure_client)
    end
  end

  describe "#load_extension_schedule" do
    it "upserts schedule for each extension" do
      extension = instance_double Terminus::Structs::Extension, to_schedule: ["extension-test", {cron: "* * * * *"}]
      allow(extension_repository).to receive(:all).and_return([extension])

      provider.send :load_extension_schedule

      expect(schedule).to have_received(:upsert).with("extension-test", {cron: "* * * * *"})
    end
  end
end
