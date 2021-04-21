module Decidim
  module Initiatives
    class EndOfMandateArchivist
      def initialize(category_name)
        @category_name = find_or_create(category_name)
      end

      def self.archive(category_name)
        self.new(category_name).call
      end

      def call

      end

      def find_or_create(category_name)
        Decidim::Initiatives::ArchiveCategory.find_or_create_by(name: category_name)
      end
    end
  end
end
