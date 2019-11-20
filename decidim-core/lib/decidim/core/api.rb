# frozen_string_literal: true

module Decidim
  module Core
    autoload :ParticipatorySpaceInterface, "decidim/api/participatory_space_interface"
    autoload :ComponentInterface, "decidim/api/component_interface"
    autoload :AuthorInterface, "decidim/api/author_interface"
    autoload :AuthorableInterface, "decidim/api/authorable_interface"
    autoload :CategorizableInterface, "decidim/api/categorizable_interface"
    autoload :ScopableInterface, "decidim/api/scopable_interface"
    autoload :AttachableInterface, "decidim/api/attachable_interface"
    autoload :HashtagInterface, "decidim/api/hashtag_interface"

    autoload :AttachmentType, "decidim/core/attachment_type"
    autoload :CategoryType, "decidim/core/category_type"
    autoload :ComponentType, "decidim/core/component_type"
    autoload :CoordinatesType, "decidim/core/coordinates_type"
    autoload :DateTimeType, "decidim/core/date_time_type"
    autoload :DateType, "decidim/core/date_type"
    autoload :DecidimType, "decidim/core/decidim_type"
    autoload :HashtagType, "decidim/core/hashtag_type"
    autoload :LocalizedStringType, "decidim/core/localized_string_type"
    autoload :MetricHistoryType, "decidim/core/metric_history_type"
    autoload :MetricType, "decidim/core/metric_type"
    autoload :OrganizationType, "decidim/core/organization_type"
    autoload :ParticipatorySpaceType, "decidim/core/participatory_space_type"
    autoload :ScopeApiType, "decidim/core/scope_api_type"
    autoload :SessionType, "decidim/core/session_type"
    autoload :StatisticType, "decidim/core/statistic_type"
    autoload :TranslatedFieldType, "decidim/core/translated_field_type"
    autoload :UserGroupType, "decidim/core/user_group_type"
    autoload :UserType, "decidim/core/user_type"
  end
end
