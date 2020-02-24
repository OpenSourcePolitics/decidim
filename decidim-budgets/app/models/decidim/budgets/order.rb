# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and component and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::DataPortability
      include Decidim::NewsletterParticipant

      component_manifest_name "budgets"

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"

      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_order_id", dependent: :destroy
      has_many :projects, through: :line_items, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"

      validates :user, uniqueness: { scope: :component }
      validate :user_belongs_to_organization

      validates :total_budget, numericality: { greater_than_or_equal_to: :minimum_budget }, if: :checked_out_and_per_budget?
      validates :total_budget, numericality: { less_than_or_equal_to: :maximum_budget }, if: :per_budget?

      validates :total_projects, numericality: { less_than_or_equal_to: :number_of_projects }, if: :per_project?
      # i18n-tasks-use t('activerecord.errors.messages.equal_to')
      validates :total_projects, numericality: { equal_to: :number_of_projects }, if: :checked_out_and_per_project?

      validate :projects_per_category_treshold_must_be_reached, if: :checked_out_and_per_category?

      scope :finished, -> { where.not(checked_out_at: nil) }
      scope :pending, -> { where(checked_out_at: nil) }

      # Public: Returns the sum of project budgets
      def total_budget
        projects.to_a.sum(&:budget)
      end

      # Public: Returns true if the order has been checked out
      def checked_out?
        checked_out_at.present?
      end

      # Public: Returns true if the order exist but has not been checked out
      def pending?
        checked_out_at.nil? && !line_items.empty?
      end

      # Public: Returns the order budget percent from the settings total budget
      def budget_percent
        (total_budget.to_f / component.settings.total_budget.to_f) * 100
      end

      # Public: Returns the order progress percent from the settings total projects
      def project_percent
        (total_projects.to_f / component.settings.total_projects.to_f) * 100
      end

      # Public: Returns the required minimum budget to checkout
      def minimum_budget
        return 0 unless component

        component.settings.total_budget.to_f * (component.settings.vote_threshold_percent.to_f / 100)
      end

      # Public: Returns true if the order has been checked out and is budget type
      def checked_out_and_per_budget?
        checked_out? && per_budget?
      end

      # Public: Returns true if the order has been checked out and is project type
      def checked_out_and_per_project?
        checked_out? && per_project?
      end

      # Public: Returns true if the order has been checked out and is category type
      def checked_out_and_per_category?
        checked_out? && per_category?
      end

      # Public: Returns true if the component settings `vote_per_project` is enabled
      def per_project?
        component&.settings&.vote_per_project?
      end

      # Public: Returns true if the number of projects required is reached
      def limit_project_reached?
        return false unless per_project?

        total_projects == number_of_projects
      end

      # Public: Returns true if the component settings `vote_per_budget` is enabled
      def per_budget?
        component&.settings&.vote_per_budget?
      end

      # Public: Returns true if the minimum budget required is reached
      def budget_treshold_reached?
        return false unless per_budget?

        total_budget.to_f >= minimum_budget
      end

      # Public: Returns true if the component settings `vote_per_category` is enabled
      def per_category?
        component.settings.vote_per_category?
      end

      # Public: Returns true if the minimum projects per category required is reached
      def category_threshold_reached?
        return false unless per_category?

        projects_per_category_treshold.all? do |category_id, minimum_projects|
          projects_per_category.fetch(category_id, 0) >= minimum_projects
        end
      end

      # Public: Returns the minimum projects per category required based on component settings
      # Returns a Hash
      def projects_per_category_treshold
        @projects_per_category_treshold ||= self.class.projects_per_category_treshold(component)
      end

      # Public: groups the projects per category and counts them
      # Returns a Hash
      def projects_per_category
        projects.joins(:categorization).group(:decidim_category_id).count.transform_keys do |key|
          subcategories.has_key?(key) ? subcategories[key] : key
        end
      end

      # Public: Returns the number of projects added to the order
      # Returns an Integer
      def total_projects
        projects.size
      end

      # Public: Returns the number of projects remaining to reach the number of projects required
      # Returns an Integer
      def remaining_projects
        number_of_projects - total_projects
      end

      # Public: Returns true if all requirements are met based on component settings
      def can_checkout?
        requirements = []
        requirements << budget_treshold_reached? if per_budget?
        requirements << limit_project_reached? if per_project?
        requirements << category_threshold_reached? if per_category?
        requirements.all?
      end

      # Public: Returns the number of projects required based on component settings
      # Returns an Integer
      def number_of_projects
        component.settings.total_projects
      end

      # Public: Returns the maximum budget allowed based on component settings
      # Returns an Integer
      def maximum_budget
        return 0 unless component || !per_project?

        component&.settings&.total_budget.to_f
      end

      # Public: Returns a component `projects_per_category_treshold` Hash,
      # with key-values as Integer and keeping only positive values.
      # This logic is in a class method to be able to call it when there isn't a current_order yet.
      # See helpers/decidim/budgets/projects_helper.rb
      # Returns a Hash
      def self.projects_per_category_treshold(component)
        component.settings.projects_per_category_treshold.each_with_object({}) do |(k, v), hsh|
          next if v.to_i.zero?

          hsh[k.to_i] = v.to_i
        end
      end

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Budgets::DataPortabilityBudgetsOrderSerializer
      end

      def self.newsletter_participant_ids(component)
        Decidim::Budgets::Order.where(component: component).joins(:component)
                               .finished
                               .pluck(:decidim_user_id).flatten.compact.uniq
      end

      private

      def subcategories
        @subcategories ||= component.categories.pluck(:id, :parent_id).to_h.delete_if { |_k, v| v.nil? }
      end

      def user_belongs_to_organization
        organization = component&.organization

        return if !user || !organization

        errors.add(:user, :invalid) unless user.organization == organization
      end

      # Private: validates the minimum projects per category required is reached
      def projects_per_category_treshold_must_be_reached
        errors.add(:projects, :invalid) unless category_threshold_reached?
      end
    end
  end
end
