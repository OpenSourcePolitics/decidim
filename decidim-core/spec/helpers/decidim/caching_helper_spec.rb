# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CachingHelper do
    describe "#cache_with_url" do
      let(:subject) { helper.cache_with_url(name, options) }
      let(:options) do
        {
          collection: "dummy_collection",
          url: decidim.root_url(host: organization.host)
        }
      end
      let(:organization) { create(:organization) }
      let(:md5_digest) { Digest::MD5.hexdigest("#{options[:collection]}#{options[:url]}") }
      let(:name) { "dummy_name" }

      it "returns a string" do
        expect(subject).to be_a String
      end

      it "returns the cache version name" do
        expect(subject).to eq("dummy_name/#{md5_digest}")
      end

      context "when cache is already set" do
        before do
          Rails.cache.write("dummy_key", md5_digest)
        end

        it "returns the cache version name" do
          expect(subject).to eq("dummy_name/#{md5_digest}")
        end
      end

      context "when collection is different" do
        let(:options) do
          {
            collection: "dummy_collection_different",
            url: decidim.root_url(host: organization.host)
          }
        end

        it "generate a different hash" do
          old_hash = helper.cache_with_url(name, collection: "dummy_collection", url: decidim.root_url(host: organization.host))
          expect(subject).not_to eq(old_hash)
        end
      end

      context "when option is missing" do
        context "when collection is missing" do
          let(:options) do
            {
              collection: nil,
              url: decidim.root_url(host: organization.host)
            }
          end

          it "returns the cache version name" do
            expect(subject).to eq("dummy_name/#{md5_digest}")
          end
        end

        context "when url is missing" do
          let(:options) do
            {
              collection: "dummy_collection",
              url: nil
            }
          end

          it "returns the cache version name" do
            expect(subject).to eq("dummy_name/#{md5_digest}")
          end
        end

        context "when name is nil" do
          let(:name) { nil }

          it "returns a default name" do
            expect(subject).to eq("decidim_cached_with_url/#{md5_digest}")
          end
        end
      end

      context "when collection is a TreeNode" do
        let(:options) do
          {
            collection: CheckBoxesTreeHelper::TreeNode.new(
              CheckBoxesTreeHelper::TreePoint.new("", "All"),
              [
                CheckBoxesTreeHelper::TreePoint.new("open", "Open"),
                CheckBoxesTreeHelper::TreeNode.new(
                  CheckBoxesTreeHelper::TreePoint.new("closed", "Closed"),
                  [
                    CheckBoxesTreeHelper::TreePoint.new("accepted", "Accepted"),
                    CheckBoxesTreeHelper::TreePoint.new("rejected", "Rejected")
                  ]
                )
              ]
            ),
            url: decidim.root_url(host: organization.host)
          }
        end

        it "returns the cache version name" do
          expect(subject).to eq("dummy_name/#{md5_digest}")
        end
      end
    end
  end
end
