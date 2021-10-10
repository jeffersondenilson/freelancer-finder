class AddFieldsToProfessionals < ActiveRecord::Migration[6.1]
  def change
    add_column :professionals, :full_name, :string, default: ""
    add_column :professionals, :birth_date, :date, default: ""
    add_column :professionals, :education, :text, default: ""
    add_column :professionals, :description, :text, default: ""
    add_column :professionals, :experience, :text, default: ""
    add_column :professionals, :abilities, :text, default: ""
    add_column :professionals, :profile_picture_url, :string, default: ""
    add_column :professionals, :completed_profile, :boolean, default: false
  end
end
