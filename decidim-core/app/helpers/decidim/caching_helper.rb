# frozen_string_literal: true

module Decidim
  # Helpers related to caching
  module CachingHelper
    # cache_with_url fetch in Rails cache the wanted cache key or create it.
    # @param [String] name - Name of the cache key : Default "decidim_cached_with_url"
    # @param [Hash] options - Takes a collection (String, Array, Decidim::CheckBoxesTreeHelper::TreeNode, or other) and a url (String)
    # @return [String] - Cache key
    def cache_with_url(name, options = {})
      md5_digest = Digest::MD5.hexdigest("#{options[:collection]}#{options[:url]}")

      name ||= "decidim_cached_with_url"
      cache_key = "#{name}/#{md5_digest}"

      Rails.cache.fetch(cache_key) do
        cache_key
      end
    end
  end
end
