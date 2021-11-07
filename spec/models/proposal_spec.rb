require 'rails_helper'

RSpec.describe Proposal, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  it { should belong_to :project }
  it { should belong_to :professional }
  it { should have_one :proposal_cancelation }
  it {
    should define_enum_for(:status)
      .with_values(
        pending: 0, analyzing: 10, approved: 20, canceled_pending: 30,
        canceled_approved: 40
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

  context '#can_cancel_at_current_date?' do
    it 'return true if approved the same day' do
      jane = User.create!(
        name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456'
      )
      pj1 = Project.create!(
        title: 'Projeto 1',
        description: 'lorem ipsum...',
        desired_abilities: 'design',
        value_per_hour: 12.34,
        due_date: '09/10/2021',
        remote: true,
        creator: jane
      )
      john = Professional.create!(
        name: 'John Doe', email: 'john.doe@email.com', password: '123456',
        birth_date: '01/01/1980', completed_profile: true
      )
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: john,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at do
        expect(prop1.can_cancel_at_current_date?).to eq(true)
        expect(prop1.errors.empty?).to eq(true)
      end
    end

    it 'return true if approved in less than three days' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      john = Professional.create!(
        name: 'John Doe', email: 'john.doe@email.com',
        password: '123456', birth_date: '01/01/1980',
        completed_profile: true
      )
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: john,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at + 2.days do
        expect(prop1.can_cancel_at_current_date?).to eq(true)
        expect(prop1.errors.empty?).to eq(true)
      end
    end

    it 'return false if was approved in more than three days' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at + 3.days do
        expect(prop1.can_cancel_at_current_date?).to eq(false)
        expect(prop1.errors.full_messages_for(:approved_at)).to include(
          'Aprovada em 01/01/2021. '\
          'Não é possível cancelar a proposta após 3 dias.'
        )
      end
    end
  end

  context '#cancel!' do
    it 'cancel pending proposal' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :pending
      )

      expect(prop1.cancel!).to eq(true)
      expect(prop1.status).to eq('canceled_pending')
    end

    it 'cancel approved proposal with cancel reason' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at do
        expect(prop1.cancel!('I Cancel')).to eq(true)
        expect(prop1.errors.empty?).to eq(true)
        expect(prop1.status).to eq('canceled_approved')
        expect(prop1.proposal_cancelation.cancel_reason).to eq('I Cancel')
      end
    end

    it 'cancel approved proposal with empty cancel reason' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at do
        expect(prop1.cancel!).to eq(true)
        expect(prop1.errors.empty?).to eq(true)
        expect(prop1.status).to eq('canceled_approved')
        expect(prop1.proposal_cancelation.cancel_reason).to eq('')
      end
    end

    it 'return false if approved in more than three days' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                          password: '123456')
      pj1 = Project.create!(
        title: 'Projeto 1', description: 'lorem ipsum...',
        desired_abilities: 'design', value_per_hour: 12.34,
        due_date: '09/10/2021', remote: true, creator: jane
      )
      professional = create(:completed_profile_professional)
      prop1 = Proposal.create!(
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: '10/01/2021',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: '01/01/2021'
      )

      travel_to prop1.approved_at + 3.days do
        expect(prop1.cancel!).to eq(false)
        expect(prop1.errors.full_messages_for(:approved_at)).to include(
          'Aprovada em 01/01/2021. Não é possível cancelar a proposta após 3 '\
          'dias.'
        )
        expect(prop1.status).to eq('approved')
      end
    end
  end
end
