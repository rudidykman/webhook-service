class CreateApplicationsAndEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :external_id, unique: true, null: false
      t.string :project, unique: true, null: false

      t.timestamps
    end

    create_table :events do |t|
      t.string :external_id, unique: true, null: false
      t.references :application, foreign_key: true
      t.string :status, null: false
      t.string :failure_reason

      t.timestamps
    end
  end
end
