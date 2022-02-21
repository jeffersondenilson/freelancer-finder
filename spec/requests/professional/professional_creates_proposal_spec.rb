require 'rails_helper'

describe 'Professional creates proposal' do
  it 'and should not create proposal on unexistent project' do
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

  it 'and should not create proposal as another professional' do
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

  it 'and should not choose proposal status when create' do
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

  it 'and should not choose proposal status when update' do
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

  it 'and should not create two proposals in a project' do
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

  it 'and should create proposal with canceled proposal in same project' do
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

  it 'and should not update refused proposal' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.professional, scope: :professional
    put '/proposals/1', params: {
      proposal: {
        message: 'Should not be updated',
        value_per_hour: 10,
        hours_per_week: 10,
        finish_date: 3.days.from_now
      }
    }

    expect(Proposal.first.status).to eq('refused')
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq('Propostas recusadas não podem ser alteradas')
  end

  it 'and should not create proposal in project with refused proposal' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.professional, scope: :professional

    post '/projects/1/proposals', params: {
      message: 'Should not create',
      value_per_hour: 10,
      hours_per_week: 10,
      finish_date: 3.days.from_now
    }

    expect(Proposal.count).to eq(1)
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq(
      'Você já tem uma proposta recusada nesse projeto'
    )
  end

  it 'and should not see new proposal form in project with refused proposal' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.professional, scope: :professional

    get '/projects/1/proposals/new'

    expect(Proposal.count).to eq(1)
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq(
      'Você já tem uma proposta recusada nesse projeto'
    )
  end

  it 'and should not update approved proposal' do
    proposal = create(:proposal)
    proposal.approved!

    login_as proposal.professional
    put '/proposals/1/', params: {
      proposal: {
        message: 'Should not update',
        value_per_hour: 99.99,
        hours_per_week: 30,
        finish_date: 1.week.from_now
      }
    }

    expect(proposal.status).to eq('approved')
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq('Não é possível alterar as informações de '\
                                'uma proposta aprovada')
  end
end
