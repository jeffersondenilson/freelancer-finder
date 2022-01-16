class CreateProposalRefusals < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_refusals do |t|
      t.text :refuse_reason, default: ""
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
