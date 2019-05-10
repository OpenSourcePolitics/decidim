# frozen_string_literal: true

namespace :decidim do
  namespace :budgets do
    desc "Setup environment so that only decidim migrations are installed."
    task reminder: :environment do
      pending_orders = Decidim::Budgets::Order.where(checked_out_at: nil).where("updated_at > ?", 24.hours.ago)

      notify_user(pending_orders)
    end
  end
end

def notify_user(orders)
  orders.each do |order|
    Decidim::EventsManager.publish(
      event: "decidim.events.budgets.reminder_order",
      event_class: Decidim::Budgets::ReminderOrderEvent,
      resource: order.component,
      affected_users: [order.user]
    )
  end
end
