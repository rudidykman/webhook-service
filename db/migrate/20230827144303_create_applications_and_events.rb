class CreateApplicationsAndEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :project, index: true

      t.timestamps
    end

    create_table :events do |t|
      t.references :application, foreign_key: true
      t.string :status
      t.string :failure_reason

      t.timestamps
    end
  end
end
