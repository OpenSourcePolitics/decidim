# frozen_string_literal: true

module Decidim
  # Helpers related to caching
  module CachingHelper
    def cache_with_url(options = {})
      md5_digest = Digest::MD5.hexdigest("#{options[:collection]}#{options[:url]}")

      Rails.cache.fetch("#{options.fetch(:name, "decidim_cached_with_url")}/#{md5_digest}") do
        "#{options.fetch(:name, "decidim_cached_with_url")}/#{md5_digest}"
      end
    end
  end
end
