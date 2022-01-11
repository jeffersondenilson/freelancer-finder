require 'rails_helper'

describe 'Professional creates proposal' do
  it 'can not create proposal on unexistent project' do
    professional = create(:completed_profile_professional)
    login_as professional, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now
      }
    }

    expect(response).to have_http_status(:not_found)
    expect(Proposal.count).to eq(0)
  end

  it 'can not create proposal as another professional' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:completed_profile_professional)
    another_professional = create(:completed_profile_professional)
    login_as professional, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'NOT John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now,
        professional: another_professional
      }
    }

    expect(another_professional.proposals.count).to eq(0)
    expect(professional.proposals.count).to eq(1)
    expect(Proposal.first.professional_id).to eq(professional.id)
  end

  it 'can not choose proposal status when create' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:completed_profile_professional)
    login_as professional, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now,
        status: :approved
      }
    }

    expect(Proposal.first.status).to eq('pending')
  end

  it 'can not choose proposal status when update' do
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
      finish_date: 3.days.from_now,
      project: pj1,
      professional: professional
    )
    login_as professional, scope: :professional

    put '/proposals/1', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now,
        status: :canceled_approved
      }
    }

    expect(Proposal.first.status).to eq('pending')
  end

  it 'can not create two proposals in a project' do
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
      finish_date: 3.days.from_now,
      project: pj1,
      professional: professional
    )
    login_as professional, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now
      }
    }

    expect(flash[:alert]).to eq('Você já fez uma proposta nesse projeto')
    expect(response).to redirect_to('/projects/1')
  end

  it 'and can create proposal with canceled proposal in same project' do
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
      finish_date: 3.days.from_now,
      project: pj1,
      professional: professional,
      status: :canceled_approved
    )
    login_as professional, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s new proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now
      }
    }

    expect(flash[:alert]).to be_nil
    expect(flash[:notice]).to eq('Proposta criada com sucesso')
    expect(response).to redirect_to(project_path(pj1))
  end
end
