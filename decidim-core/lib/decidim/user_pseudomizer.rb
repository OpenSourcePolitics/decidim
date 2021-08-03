# frozen_string_literal: true

module Decidim
  class UserPseudomizer
    HASHED_ATTRIBUTES = [:name, :nickname, :email, :organization, :id, :personal_url, :about].freeze

    def initialize(user)
      @user = user
    end

    def self.pseudomize(user)
      new(user)
    end

    def hash
      @hash ||= Digest::SHA2.hexdigest("#{salt}#{user_hash}")
    end

    def name
      "Anonyme_#{hash}"
    end

    def nickname
      "Anonyme_#{hash}"
    end

    def email
      "#{hash}@anonyme.org"
    end

    private

    def salt
      Rails.application.secrets.secret_key_base
    end

    def user_hash
      HASHED_ATTRIBUTES.map { |attr| @user.send(attr) }.join(" ")
    end
  end
end
