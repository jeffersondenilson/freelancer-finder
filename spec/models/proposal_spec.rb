require 'rails_helper'

RSpec.describe Proposal, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context 'associations' do
    it { should belong_to :project }
    it { should belong_to :professional }
    it { should have_one :proposal_cancelation }
  end

  context 'validations' do
    it {
      should define_enum_for(:status)
        .with_values(
          pending: 0, analyzing: 10, approved: 20, canceled_pending: 30,
          canceled_approved: 40, refused: 50
        )
    }
    it { should validate_presence_of :message }
    it { should validate_presence_of :value_per_hour }
    it { should validate_presence_of :hours_per_week }
    it { should validate_presence_of :finish_date }
    it { should validate_numericality_of :value_per_hour }
    it {
      should validate_numericality_of(:hours_per_week)
        .only_integer
        .is_greater_than(0)
    }
  end

  context '#can_cancel_at_current_date?' do
    context 'should permit cancelation' do
      it 'if approved the same day' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at do
          expect(proposal.can_cancel_at_current_date?).to eq(true)
          expect(proposal.errors.empty?).to eq(true)
        end
      end

      it 'if approved in less than three days' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at + 2.days do
          expect(proposal.can_cancel_at_current_date?).to eq(true)
          expect(proposal.errors.empty?).to eq(true)
        end
      end
    end

    context 'should not permit cancelation' do
      it 'if was approved in more than three days' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at + 3.days do
          expect(proposal.can_cancel_at_current_date?).to eq(false)
          expect(proposal.errors.full_messages_for(:approved_at)).to include(
            'Aprovada em 15/01/2022. '\
            'Não é possível cancelar a proposta após 3 dias.'
          )
        end
      end

      it 'if refused' do
        proposal = create(:proposal)
        proposal.refused!
        ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

        expect(proposal.can_cancel_at_current_date?).to eq(false)
        expect(proposal.errors.empty?).to eq(true)
      end

      it 'if canceled_pending' do
        proposal = create(:proposal)
        proposal.canceled_pending!

        expect(proposal.can_cancel_at_current_date?).to eq(false)
        expect(proposal.errors.empty?).to eq(true)
      end

      it 'if canceled_approved' do
        proposal = create(:proposal)
        proposal.canceled_approved!
        ProposalCancelation.create!(proposal: proposal, cancel_reason: 'Cancel')

        expect(proposal.can_cancel_at_current_date?).to eq(false)
        expect(proposal.errors.empty?).to eq(true)
      end
    end
  end

  context '#cancel!' do
    context 'should cancel' do
      it 'pending proposal' do
        proposal = create(:proposal)

        expect(proposal.cancel!).to eq(true)
        expect(proposal.status).to eq('canceled_pending')
      end

      it 'approved proposal with cancel reason' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at do
          expect(proposal.cancel!('I Cancel')).to eq(true)
          expect(proposal.errors.empty?).to eq(true)
          expect(proposal.status).to eq('canceled_approved')
          expect(proposal.proposal_cancelation.cancel_reason).to eq('I Cancel')
        end
      end

      it 'approved proposal with empty cancel reason' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at do
          expect(proposal.cancel!).to eq(true)
          expect(proposal.errors.empty?).to eq(true)
          expect(proposal.status).to eq('canceled_approved')
          expect(proposal.proposal_cancelation.cancel_reason).to eq('')
        end
      end
    end

    context 'should not cancel' do
      it 'if approved in more than three days' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        travel_to proposal.approved_at + 3.days do
          expect(proposal.cancel!).to eq(false)
          expect(proposal.errors.full_messages_for(:approved_at)).to include(
            'Aprovada em 15/01/2022. Não é possível cancelar a proposta após '\
            '3 dias.'
          )
          expect(proposal.status).to eq('approved')
        end
      end

      it 'if refused' do
        proposal = create(:proposal)
        proposal.refused!
        ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

        expect(proposal.cancel!).to eq(false)
        expect(ProposalCancelation.count).to eq(0)
      end

      it 'if canceled_pending' do
        proposal = create(:proposal)
        proposal.canceled_pending!

        expect(proposal.cancel!).to eq(false)
        expect(ProposalCancelation.count).to eq(0)
      end

      it 'if canceled_approved' do
        proposal = create(:proposal)
        proposal.canceled_approved!
        ProposalCancelation.create!(proposal: proposal, cancel_reason: 'Cancel')

        expect(proposal.cancel!).to eq(false)
      end
    end
  end

  context '#approved_date' do
    it 'should set approved_at when approved' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      proposal = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :pending
      )

      travel_to '2022-01-06' do
        proposal.approved!
      end

      expect(proposal.status).to eq('approved')
      expect(proposal.approved_at).to eq('2022-01-06')
    end
  end

  context '#refuse!' do
    context 'should refuse' do
      it 'if pending' do
        proposal = create(:proposal)

        proposal.refuse!('Refused!')

        expect(Proposal.first.status).to eq('refused')
        expect(ProposalRefusal.first.refuse_reason).to eq('Refused!')
      end

      it 'if approved' do
        proposal = create(
          :proposal, status: :approved, approved_at: '15/01/2022'
        )

        proposal.refuse!('Refused!')

        expect(Proposal.first.status).to eq('refused')
        expect(ProposalRefusal.first.refuse_reason).to eq('Refused!')
      end
    end

    context 'should not refuse' do
      it 'if canceled_pending' do
        proposal = create(:proposal)
        proposal.canceled_pending!

        expect(proposal.refuse!).to eq(false)
        expect(Proposal.first.status).to eq('canceled_pending')
      end

      it 'if canceled_approved' do
        proposal = create(:proposal)
        proposal.canceled_approved!
        ProposalCancelation.create!(
          proposal: proposal, cancel_reason: 'Canceled'
        )

        expect(proposal.refuse!).to eq(false)
        expect(Proposal.first.status).to eq('canceled_approved')
      end

      it 'if already refused' do
        proposal = create(:proposal)
        proposal.refused!
        ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused')

        expect(proposal.refuse!).to eq(false)
        expect(Proposal.first.status).to eq('refused')
      end
    end
  end
end
