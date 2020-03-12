# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentSerializer do
      let(:comment) { create(:comment) }
      let(:subject) { described_class.new(comment) }

      describe "#serialize" do
        it "includes the id" do
          expect(subject.serialize).to include(id: comment.id)
        end

        it "includes the creation date" do
          expect(subject.serialize).to include(created_at: comment.created_at)
        end

        it "includes the body" do
          expect(subject.serialize).to include(body: comment.body)
        end

        it "includes the author" do
          expect(subject.serialize[:author]).to(
            include(id: comment.author.id, name: comment.author.name)
          )
        end

        it "includes the alignment" do
          expect(subject.serialize).to include(alignment: comment.alignment)
        end

        it "includes the depth" do
          expect(subject.serialize).to include(alignment: comment.depth)
        end

        it "includes the root commentable's url" do
          expect(subject.serialize[:root_commentable_url]).to match(/http/)
        end

        it "includes authors metadata" do
          expect(subject.serialize[:author]).to include(birth_date: comment.author.registration_metadata[:birth_date.to_s].to_s)
          expect(subject.serialize[:author]).to include(gender: comment.author.registration_metadata[:gender.to_s])
          expect(subject.serialize[:author]).to include(work_area: comment.author.registration_metadata[:work_area.to_s])
          expect(subject.serialize[:author]).to include(residential_area: comment.author.registration_metadata[:residential_area.to_s])
          expect(subject.serialize[:author]).to include(statutory_representative_email: comment.author.registration_metadata[:statutory_representative_email.to_s])
        end
      end
    end
  end
end
