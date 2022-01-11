require 'rails_helper'

describe 'Professional cancel proposal' do
  include ActiveSupport::Testing::TimeHelpers

  it 'can not cancel approved proposal after three days' do
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
      finish_date: Time.current + 3.days,
      status: :approved,
      approved_at: '10/10/2021',
      project: pj1,
      professional: professional
    )
    login_as professional, scope: :professional

    delete '/proposals/1', params: {
      proposal: {
        cancel_reason: 'cancel it'
      }
    }

    travel_to prop1.approved_at + 3.days do
      expect(response.body).to include(
        'Aprovada em 10/10/2021. '\
        'Não é possível cancelar a proposta após 3 dias.'
      )
      expect(Proposal.first.status).to eq('approved')
    end
  end

  it 'can not view cancel form if is pending' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:completed_profile_professional)
    Proposal.create!(
      message: 'John\'s proposal on project 1',
      value_per_hour: 80.80,
      hours_per_week: 20,
      finish_date: Time.current + 3.days,
      status: :pending,
      project: pj1,
      professional: professional
    )
    login_as professional, scope: :professional

    get '/proposals/1/cancel'

    expect(response).to redirect_to('/projects/my')
    expect(flash[:notice]).to eq('Proposta cancelada com sucesso')
    expect(Proposal.first.status).to eq('canceled_pending')
  end
end
