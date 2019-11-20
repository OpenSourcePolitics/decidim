# frozen_string_literal: true

require "decidim/pages/admin"
require "decidim/pages/engine"
require "decidim/pages/admin_engine"
require "decidim/pages/component"

module Decidim
  # This namespace holds the logic of the `Pages` component. This component
  # allows the admins to create a custom page for a participatory process.
  module Pages
    autoload :PageType, "decidim/pages/page_type"
    autoload :PagesType, "decidim/pages/pages_type"
  end
end
