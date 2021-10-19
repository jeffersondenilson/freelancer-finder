class Proposal < ApplicationRecord
  belongs_to :project
  belongs_to :professional

  enum status: { pending: 0, analyzing: 10, approved: 20, canceled: 30 }

  validates :message, :value_per_hour, :hours_per_week, :finish_date,
    presence: true

  validates :value_per_hour, numericality: true
  
  validates :hours_per_week, numericality: { only_integer: true, greater_than: 0 }

  def can_cancel_at_current_date?
    return true if approved? && Date.current < (approved_at + 3.day).to_date

    errors.add(:approved_at, "#{I18n.l approved_at.to_date}. "\
      "Não é possível cancelar a proposta após 3 dias.")
    
    return false
  end
end
