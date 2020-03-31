# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentSerializer do
      let(:comment) { create(:comment) }
      let(:subject) { described_class.new(comment) }

      describe "#serialize" do
        it "includes the id" do
          expect(subject.serialize).to include("ID" => comment.id)
        end

        it "includes the creation date" do
          expect(subject.serialize).to include("Creation date" => comment.created_at)
        end

        it "includes the body" do
          expect(subject.serialize).to include("Content" => comment.body)
        end

        it "includes the author" do
          expect(subject.serialize["Author"]).to(
            include("ID" => comment.author.id, "Name" => comment.author.name)
          )
        end

        it "includes the alignment" do
          expect(subject.serialize).to include("Alignment" => comment.alignment)
        end

        it "includes the depth" do
          expect(subject.serialize).to include("Depth" => comment.depth)
        end

        it "includes the root commentable's url" do
          expect(subject.serialize["Root commentable URL"]).to match(/http/)
        end

        it "includes authors metadata" do
          expect(subject.serialize["Author"]).to include("Birth date" => comment.author.registration_metadata[:birth_date.to_s].to_s)
          expect(subject.serialize["Author"]).to include("Gender" => comment.author.registration_metadata[:gender.to_s])
          expect(subject.serialize["Author"]).to include("Work area" => comment.author.registration_metadata[:work_area.to_s])
          expect(subject.serialize["Author"]).to include("Residential area" => comment.author.registration_metadata[:residential_area.to_s])
          expect(subject.serialize["Author"]).to include("Statutory representative email" => comment.author.registration_metadata[:statutory_representative_email.to_s])
        end
      end
    end
  end
end
