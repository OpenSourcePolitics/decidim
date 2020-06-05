# frozen_string_literal: true

module Decidim
  # This class deals with uploading the organization's logo.
  class AreaLogoUploader < ImageUploader

    process quality: Decidim.image_uploader_quality

    version :medium do
      process resize_to_fit: [400, 160]
    end
  end
end
