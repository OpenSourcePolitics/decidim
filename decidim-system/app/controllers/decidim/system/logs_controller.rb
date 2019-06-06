# frozen_string_literal: true

module Decidim
  module System
    class LogsController < Decidim::System::ApplicationController
      def index
        @logs = `tail -n #{lines} log/#{Rails.env}.log`
      end

      def download
        send_file File.open("log/#{Rails.env}.log")
      end

      private

      def lines
        lines = params[:lines].to_i
        return 50 if lines.zero?

        lines
      end
    end
  end
end
