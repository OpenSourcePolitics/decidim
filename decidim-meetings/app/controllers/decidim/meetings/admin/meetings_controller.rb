# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meetings from a Participatory Process
      class MeetingsController < Admin::ApplicationController
        helper_method :blank_service

        def new
          enforce_permission_to :create, :meeting

          @form = form(MeetingForm).instance
        end

        def create
          enforce_permission_to :create, :meeting

          @form = form(MeetingForm).from_params(params, current_component: current_component)

          CreateMeeting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.create.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.create.invalid", scope: "decidim.meetings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = form(MeetingForm).from_model(meeting)
        end

        def update
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = form(MeetingForm).from_params(params, current_component: current_component)

          UpdateMeeting.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :meeting, meeting: meeting

          DestroyMeeting.call(meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.destroy.success", scope: "decidim.meetings.admin")

              redirect_to meetings_path
            end

            on(:invalid) do |proposals_count|
              flash.now[:alert] = I18n.t(
                "meetings.destroy.invalid.proposals_count",
                count: proposals_count,
                scope: "decidim.meetings.admin"
              )

              render action: "index"
            end
          end
        end

        private

        def blank_service
          @blank_service ||= Admin::MeetingServiceForm.new
        end
      end
    end
  end
end
