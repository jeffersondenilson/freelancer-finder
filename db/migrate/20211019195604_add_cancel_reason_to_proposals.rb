class AddCancelReasonToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :cancel_reason, :text
  end
end
