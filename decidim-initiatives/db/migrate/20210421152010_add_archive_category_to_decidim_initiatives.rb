class AddArchiveCategoryToDecidimInitiatives < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_initiatives,
                  :decidim_initiatives_archive_categories,
                  foreign_key: true,
                  index: {
                      name:
                          "index_decidim_initiatives_on_initiatives_archive_category_id"
                  }
  end
end
