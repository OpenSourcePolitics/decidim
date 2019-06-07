# frozen_string_literal: true

module Decidim
  module System
    class LogsController < Decidim::System::ApplicationController
      helper_method :search_input
      helper_method :lines

      def index
        @logs = command
      end

      def download
        send_file File.open("log/#{Rails.env}.log")
      end

      private

      def search_input
        @search_input ||= params[:search_input] || nil
      end

      def command
        if search.present?
          `tail -n #{lines} log/#{Rails.env}.log | grep "#{search}"`
        else
          `tail -n #{lines} log/#{Rails.env}.log`
        end
      end

      def lines
        lines = params[:lines].to_i
        return 50 unless (1...1001).cover?(lines)

        lines
      end

      def search
        params[:search_input]
      end
    end
  end
end
