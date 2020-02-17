# frozen_string_literal: true

module Decidim
  # This class deals with uploading banner images to ParticipatoryProcesses.
  class BannerImageUploader < ImageUploader
    process resize_to_limit: [1200, 600]
    process quality: 60

    version :md do
      process resize_to_limit: [815, 315]
    end
    version :xs do
      process resize_to_limit: [560, 315]
    end
  end
end
