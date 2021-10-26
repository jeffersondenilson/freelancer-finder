class CreateProposalCancelations < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_cancelations do |t|
      t.text :cancel_reason, default: ""
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
