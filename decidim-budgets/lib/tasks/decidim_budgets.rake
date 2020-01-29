# frozen_string_literal: true

namespace :decidim do
  namespace :budgets do
    desc "Setup environment so that only decidim migrations are installed."
    task reminder: :environment do
      notify_users(pending_orders) unless pending_orders.empty?
    end
  end

  private

  def budget_components
    Decidim::Component.where(manifest_name: "budgets")
                      .select { |component| component.current_settings.votes_enabled? }
  end

  def pending_orders
    Decidim::Budgets::Order.where(component: budget_components)
                           .where(checked_out_at: nil)
                           .where("updated_at < ?", 1.day.ago)
  end

  def notify_users(orders)
    orders.each do |order|
      Decidim::EventsManager.publish(
        event: "decidim.events.budgets.reminder_order",
        event_class: Decidim::Budgets::ReminderOrderEvent,
        resource: order.component,
        affected_users: [order.user]
      )
    end
  end
end
