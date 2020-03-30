# frozen_string_literal: true

module MetadataHelper
  def encrypted_metadata_attribute(unique_id: nil, metadata: {})
    Decidim::MetadataEncryptor.new(uid: unique_id).encrypt(metadata)
  end
end

RSpec.configure do |config|
  config.include MetadataHelper
end
