# frozen_string_literal: true

class Decidim::System::AdministrationController < Decidim::System::ApplicationController
  def index; end

  def backup
    send_file(export.path) && export.clean
  end

  private

  def export
    Decidim::System::DatabaseExport.new
  end
end
