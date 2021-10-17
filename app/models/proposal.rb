class Proposal < ApplicationRecord
  belongs_to :project
  belongs_to :professional

  enum status: { pending: 0, analyzing: 10, approved: 20 }

  validates :message, :value_per_hour, :hours_per_week, :finish_date,
    presence: true

  validates :value_per_hour, numericality: true
  
  validates :hours_per_week, numericality: { only_integer: true, greater_than: 0 }

  def can_destroy_at_current_date?

    if approved? && Date.current < (approved_at + 3.day).to_date
      min_cancel_date = (approved_at + 3.day).to_date
      days_difference = (min_cancel_date - Date.current).to_i
      
      errors.add(:approved_at, "#{I18n.l approved_at.to_date}. "\
        "Você deve esperar #{days_difference} dias para cancelar a proposta.")

      return false
    end

    return true
  end
end
