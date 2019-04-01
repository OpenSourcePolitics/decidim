# frozen_string_literal: true

module Decidim
  module System
    class DatabaseExport
      attr_reader :path

      def initialize
        @file_name = Time.zone.now.strftime("%F_%H-%M-%S")
        @path = dump_database
      end

      def clean
        Decidim::System::CleanDatabaseExportJob.perform_later(@path)
      end

      protected

      def dump_database
        system(cmd(@file_name))
        File.absolute_path(file_path(@file_name))
      end

      def cmd(file_name)
        "pg_dump -Fc -h #{host} -d #{database} -f #{file_path(file_name)}"
      end

      def database
        ActiveRecord::Base.connection_config[:database]
      end

      def host
        ActiveRecord::Base.connection_config[:host]
      end

      def file_path(time)
        Rails.root.join("backup_#{database}_#{time}.psql")
      end
    end
  end
end
