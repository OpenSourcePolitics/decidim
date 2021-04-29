# frozen_string_literal: true

module Decidim
  class InitiativesArchiveCategory < ApplicationRecord
    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"
    RESERVED_NAMES = %w(accepted rejected open closed archived answered published examinated classified debatted).freeze

    validates :name, presence: true
    validates :name,
              exclusion: {
                in: RESERVED_NAMES,
                message: "%{value} is reserved"
              }
    validates :name, uniqueness: { scope: :organization }
  end
end
