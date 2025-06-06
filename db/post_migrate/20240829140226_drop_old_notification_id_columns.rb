# frozen_string_literal: true

class DropOldNotificationIdColumns < ActiveRecord::Migration[7.1]
  DROPPED_COLUMNS = {
    notifications: %i[old_id],
    shelved_notifications: %i[old_notification_id],
    users: %i[old_seen_notification_id],
    user_badges: %i[old_notification_id],
  }

  def up
    DROPPED_COLUMNS.each { |table, columns| Migration::ColumnDropper.execute_drop(table, columns) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
