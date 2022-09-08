# frozen_string_literal: true

class AddIdeaNotificationDates < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas,
               :first_progress_notification_at, :datetime, index: true

    add_column :decidim_ideas,
               :second_progress_notification_at, :datetime, index: true
  end
end
