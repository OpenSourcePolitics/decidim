# frozen_string_literal: true

module Decidim
  # A presenter to render menus
  class MenuPresenter
    #
    # Initializes a menu for presentation
    #
    # @param name [Symbol] The name of the menu registry to be rendered
    # @param view [ActionView::Base] The view scope to render the menu
    # @param class_name [String] CSS class for the nav component
    # @param options [Hash] The rendering options for the menu entries
    #
    def initialize(name, view, class_name, options = {})
      @name = name
      @view = view
      @class_name = class_name
      @options = options
    end

    delegate :items, to: :evaluated_menu
    delegate :content_tag, :safe_join, to: :@view

    def evaluated_menu
      @evaluated_menu ||= begin
                            menu = Menu.new(@name)
                            menu.build_for(@view)
                            menu
                          end
    end

    def render
      content_tag :nav, class: @class_name do
        content_tag :ul do
          safe_join(menu_items)
        end
      end
    end

    protected

    def menu_items
      items.map do |menu_item|
        MenuItemPresenter.new(menu_item, @view, @options).render
      end
    end
  end
end
