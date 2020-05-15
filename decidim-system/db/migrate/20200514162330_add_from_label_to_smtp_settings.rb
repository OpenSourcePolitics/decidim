# frozen_string_literal: true

class AddFromLabelToSmtpSettings < ActiveRecord::Migration[5.2]
  def change
    Decidim::Organization.where.not(smtp_settings: [nil, {}]).each do |organization|
      smtp_settings = organization.smtp_settings
      if (match = smtp_settings.dig("from").match(/\A(.*)\W?\<([\w+\-.]+@[a-z\d\-.]+\.[a-z]+)\>\z/i))
        smtp_settings["from_label"] = match[1]
        smtp_settings["from_email"] = match[2]
      else
        smtp_settings["from_email"] = smtp_settings.dig("from")
      end
      # rubocop:disable Rails/SkipsModelValidations
      organization.update_columns(smtp_settings: smtp_settings)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
