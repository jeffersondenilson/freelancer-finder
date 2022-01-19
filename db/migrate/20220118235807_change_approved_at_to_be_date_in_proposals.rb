class ChangeApprovedAtToBeDateInProposals < ActiveRecord::Migration[6.1]
  def change
    change_column :proposals, :approved_at, :date
  end
end
