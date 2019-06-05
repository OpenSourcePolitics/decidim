# frozen_string_literal: true

module Decidim
  module System
    class LogsController < Decidim::System::ApplicationController
      def index
        lines = params[:lines] || 50
        @logs = `tail -n #{lines} log/#{Rails.env}.log`
      end

      def download
        send_file File.open("log/#{Rails.env}.log")
      end
    end
  end
end
