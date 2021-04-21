module Decidim
  class InitiativesArchiveCategory < ApplicationRecord
    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

    has_many :initiatives,
             class_name: "Decidim::Initiative"

    validates :name, presence: true
    validates :name, uniqueness: { scope: :organization }
  end
end
