# frozen_string_literal: true

class UpdateInitiativesGlobalScope < ActiveRecord::Migration[5.2]
  def change
    Decidim::InitiativesType.where(only_global_scope_enabled: true).each(&:save)
  end
end
