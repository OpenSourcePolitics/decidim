# frozen_string_literal: true

module Decidim
  module Api
    class TranslationController < Api::ApplicationController
      def translate
        auth_key = ENV['DEEPL_API_KEY']
        target = params[:target]
        encode_text = CGI.escape(params[:original])

        uri = URI.parse("https://api.deepl.com/v2/translate?target_lang=#{target}&text=#{encode_text}&auth_key=#{auth_key}")

        result = api_request(uri)

        render json: result
      end

      def api_request(uri)
        request = Net::HTTP::Get.new(uri)
        request.content_type = "application/json"
        req_options = {
          use_ssl: uri.scheme == "https"
        }

        Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          req = http.request(request)
          return nil if req.body.empty?

          JSON.parse(req.body)
        end
      end
    end
  end
end
