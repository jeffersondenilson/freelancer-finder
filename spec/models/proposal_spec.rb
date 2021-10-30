require 'rails_helper'

RSpec.describe Proposal, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context '#can_cancel_at_current_date?' do
    it 'return true if approved the same day' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
      pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
        desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
        remote: true, creator: jane)
      john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
        password: '123456', birth_date: '01/01/1980', completed_profile: true)
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
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
      pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
        desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
        remote: true, creator: jane)
      john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
        password: '123456', birth_date: '01/01/1980', completed_profile: true)
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

      travel_to prop1.approved_at + 2.day do
        expect(prop1.can_cancel_at_current_date?).to eq(true)
        expect(prop1.errors.empty?).to eq(true)
      end
    end

    it 'return false if was approved in more than three days' do
      jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
      pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
        desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
        remote: true, creator: jane)
      john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
        password: '123456', birth_date: '01/01/1980', completed_profile: true)
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

      travel_to prop1.approved_at + 3.day do
        expect(prop1.can_cancel_at_current_date?).to eq(false)
        expect(prop1.errors.full_messages_for(:approved_at)).to include(
          "Aprovada em 01/01/2021. Não é possível cancelar a proposta após 3 dias."
        )
      end
    end
  end
end
