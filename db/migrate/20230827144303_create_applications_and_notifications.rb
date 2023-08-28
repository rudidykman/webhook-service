class CreateApplicationsAndNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :svix_application_id, unique: true, null: false
      t.string :project, unique: true, null: false

      t.timestamps
    end

    create_table :notifications do |t|
      t.string :event_id, unique: true, null: false
      t.string :svix_message_id
      t.references :application, foreign_key: true
      t.string :status, null: false
      t.string :failure_reason

      t.timestamps
    end
  end
end
