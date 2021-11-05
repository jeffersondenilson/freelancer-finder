require 'rails_helper'

describe 'Professional creates proposal' do
  it 'can not create proposal on unexistent project' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days
      }
    }

    expect(flash[:alert]).to eq('Projeto não encontrado')
    expect(response).to redirect_to('/')
    expect(Proposal.count).to eq(0)
  end

  it 'can not create proposal as another professional' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                    desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                    remote: true, creator: jane)
    schneider = Professional.create!(name: 'Schneider', email: 'schneider@email.com',
                                     password: 'uw891#&', birth_date: '16/12/2000', completed_profile: true)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'NOT John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days,
        professional: schneider
      }
    }

    expect(schneider.proposals.count).to eq(0)
    expect(john.proposals.count).to eq(1)
    expect(Proposal.first.professional_id).to eq(john.id)
  end

  it 'can not choose proposal status when create' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                    desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                    remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days,
        status: :approved
      }
    }

    expect(Proposal.first.status).to eq('pending')
  end

  it 'can not choose proposal status when update' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                          desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                          remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    Proposal.create!(
      message: 'John\'s proposal on project 1',
      value_per_hour: 80.80,
      hours_per_week: 20,
      finish_date: Time.current + 3.days,
      project: pj1,
      professional: john
    )
    login_as john, scope: :professional

    put '/proposals/1', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days,
        status: :canceled_approved
      }
    }

    expect(Proposal.first.status).to eq('pending')
  end

  it 'can not create two proposals in a project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                          desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                          remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    Proposal.create!(
      message: 'John\'s proposal on project 1',
      value_per_hour: 80.80,
      hours_per_week: 20,
      finish_date: Time.current + 3.days,
      project: pj1,
      professional: john
    )
    login_as john, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days
      }
    }

    expect(flash[:alert]).to eq('Você já fez uma proposta nesse projeto')
    expect(response).to redirect_to('/projects/1')
  end

  it 'and can create proposal with canceled proposal in same project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                          desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                          remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456', birth_date: '01/01/1980', completed_profile: true)
    Proposal.create!(
      message: 'John\'s proposal on project 1',
      value_per_hour: 80.80,
      hours_per_week: 20,
      finish_date: Time.current + 3.days,
      project: pj1,
      professional: john,
      status: :canceled_approved
    )
    login_as john, scope: :professional

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s new proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.days
      }
    }

    expect(flash[:alert]).to be_nil
    expect(flash[:notice]).to eq('Proposta criada com sucesso')
    expect(response).to redirect_to(project_path(pj1))
  end
end
