# frozen_string_literal: true

module Decidim
  module System
    class CleanDatabaseExportJob < ApplicationJob
      queue_as :default

      def perform(export_path)
        File.delete(export_path) if File.exist?(export_path)
      end
    end
  end
end
