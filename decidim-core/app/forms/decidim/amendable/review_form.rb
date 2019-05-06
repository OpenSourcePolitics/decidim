# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class ReviewForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, String
      attribute :emendation_params, Object

      validates :id, presence: true
      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      validates :emendation_params, presence: true
      validate :check_amendable_form_validations
    end
  end
end
