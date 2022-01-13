class Proposal < ApplicationRecord
  belongs_to :project
  belongs_to :professional
  has_one :proposal_cancelation, dependent: :destroy
  has_one :proposal_refusal, dependent: :destroy

  enum status: {
    pending: 0,
    analyzing: 10,
    approved: 20,
    canceled_pending: 30,
    canceled_approved: 40,
    refused: 50
  }

  validates :message, :value_per_hour, :hours_per_week, :finish_date,
            presence: true

  validates :value_per_hour, numericality: true

  validates :hours_per_week,
            numericality: { only_integer: true, greater_than: 0 }

  before_save :approved_date, if: -> { approved? && approved_at.nil? }

  def cancel!(cancel_reason = '')
    if pending?
      canceled_pending!
    elsif can_cancel_at_current_date?
      canceled_approved!
      self.proposal_cancelation = ProposalCancelation
                                  .new(cancel_reason: cancel_reason)
    else
      return false
    end

    save
  end

  def can_cancel_at_current_date?
    return true if approved? && Date.current < (approved_at + 3.days).to_date

    errors.add(:approved_at, "#{I18n.l approved_at.to_date}. "\
                             'Não é possível cancelar a proposta após 3 dias.')

    false
  end

  # TODO: testar metodo
  def refuse!(refuse_reason = '')
    return false if canceled_pending? || canceled_approved? || refused?

    refused!
    self.proposal_refusal = ProposalRefusal
                            .new(refuse_reason: refuse_reason)

    save
  end

  private

  def approved_date
    self.approved_at = Date.current
  end
end
