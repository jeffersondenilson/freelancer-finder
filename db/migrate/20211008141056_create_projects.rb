class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.text :desired_abilities, null: false, default: ""
      t.decimal :value_per_hour, null: false, default: 0
      t.date :due_date, null: false
      t.boolean :remote, null: false

      t.timestamps
    end
  end
end
