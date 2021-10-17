class AddApprovedAtToProposal < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :approved_at, :datetime
  end
end
