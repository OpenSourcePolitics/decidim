# frozen_string_literal: true

module Decidim
  class UpstreamAcceptedEvent < Decidim::UpstreamEvent
    def event_has_roles?
      false
    end
  end
end
