# frozen_string_literal: true

require "spec_helper"
require "carrierwave/test/matchers"

module Decidim
  describe ImageUploader do
    include CarrierWave::Test::Matchers

    let(:organization) { build(:organization) }
    let(:user) { build(:user, organization: organization) }
    let(:uploader) { ImageUploader.new(user, :avatar) }

    context "when avatar is jpg type" do
      let(:avatar) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

      before do
        ImageUploader.enable_processing = true
        File.open(avatar) { |f| uploader.store!(f) }
      end

      after do
        ImageUploader.enable_processing = false
        uploader.remove!
      end

      it "compress the image" do
        expect(uploader.file.size).to be < File.size(avatar)
      end

      it "makes the image readable only to the owner and not executable" do
        expect(uploader).to have_permissions(0o666)
      end

      it "has the correct format" do
        expect(uploader).to be_format("jpeg")
      end
    end

    context "when avatar is svg type" do
      let(:avatar) { Decidim::Dev.test_file("avatar.svg", "image/svg+xml") }

      before do
        ImageUploader.enable_processing = true
        File.open(avatar) { |f| uploader.store!(f) }
      end

      after do
        ImageUploader.enable_processing = false
        uploader.remove!
      end

      it "doesn't compress the image" do
        expect(uploader.file.size).to eq(File.size(avatar))
      end

      it "has the correct format" do
        expect(uploader).to be_format("svg")
      end

      it "content type contains svg" do
        expect(uploader.content_type).to include("svg")
      end
    end
  end
end