# frozen_string_literal: true

module Decidim
  class UpstreamPendingEvent < Decidim::UpstreamEvent
    def event_has_roles?
      true
    end
  end
end
