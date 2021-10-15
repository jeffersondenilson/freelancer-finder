class CreateProposals < ActiveRecord::Migration[6.1]
  def change
    create_table :proposals do |t|
      t.text :message, null: false, default: ""
      t.decimal :value_per_hour, null: false, default: 0
      t.integer :hours_per_week, null: false, default: 1
      t.date :finish_date, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
