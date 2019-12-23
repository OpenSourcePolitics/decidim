# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user
    include JsonbAttributes

    GENDER_TYPES = %w(male female other).freeze

    MONTHNAMES = (1..12).map { |m| Date::MONTHNAMES[m] }.freeze

    attribute :name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :residential_area, String
    attribute :work_area, String
    attribute :gender, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    jsonb_attribute :birth_date, [
        [:month, String],
        [:year, String]
    ]
    attribute :underage, Boolean
    attribute :statutory_representative_email, String

    validates :name, presence: true
    validates :nickname, presence: true, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, password: { name: :name, email: :email, username: :nickname }, presence: true, confirmation: true
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validate :email_unique_in_organization
    validate :nickname_unique_in_organization

    validates :gender,
              inclusion: { in: GENDER_TYPES },
              if: ->(form) { form.gender.present? }

    validates :residential_area,
              inclusion: { in: :scopes_ids },
              presence: true

    validates :work_area,
              inclusion: { in: :scopes_ids },
              if: ->(form) { form.work_area.present? }

    validates :month,
              inclusion: { in: MONTHNAMES },
              presence: true

    validates :year,
              inclusion: { in: :year_for_select },
              presence: true

    validates :statutory_representative_email,
              'valid_email_2/email': { disposable: true },
              presence: true,
              if: ->(form) { form.underage.present? }

    def map_model(model)
      self.month = model.birth_date["month"]
      self.year = model.birth_date["year"]
    end

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    def residential_area_for_select
      scopes
    end

    def work_area_for_select
      scopes
    end

    def gender_types_for_select
      GENDER_TYPES.map do |type|
        [
            I18n.t(type.downcase, scope: "decidim.devise.registrations.new.gender"),
            type
        ]
      end
    end

    def month_names_for_select
      MONTHNAMES.map do |month_name|
        [
            I18n.t(month_name.downcase, scope: "decidim.devise.registrations.new.month_name"),
            month_name
        ]
      end
    end

    def year_for_select
      (Time.current.year - 100..Time.current.year).map(&:to_s).reverse
    end

    private

    def scopes
      current_organization.scopes
    end

    def scopes_ids
      current_organization.scopes.collect { |scope| scope.id.to_s }
    end

    def email_unique_in_organization
      errors.add :email, :taken if User.find_by(email: email, organization: current_organization).present?
    end

    def nickname_unique_in_organization
      errors.add :nickname, :taken if User.find_by(nickname: nickname, organization: current_organization).present?
    end
  end
end
