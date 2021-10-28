require 'rails_helper'

describe 'Professional authentication' do
  it 'must complete profile to view projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
      desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
      remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional

    get '/projects/1'

    expect(response).to redirect_to('/professionals/edit.1')
  end

  it 'must be signed in to create proposal' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
      desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
      remote: true, creator: jane)
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    
    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.day,
        project_id: 1,
        professional_id: 1
      }
    }

    expect(response).to redirect_to('/professionals/sign_in')
    expect(Proposal.count).to eq(0)
  end

  it 'can not create proposal on unexistent project' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional
    
    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: Time.current + 3.day,
        project_id: 1,
        professional: john
      }
    }

    expect(flash[:alert]).to eq('Projeto não encontrado')
    expect(response).to redirect_to('/')
    expect(Proposal.count).to eq(0)
  end

  it 'can not create proposal as another professional' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
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
        finish_date: Time.current + 3.day,
        project_id: 1,
        professional: schneider
      }
    }

    expect(schneider.proposals.count).to eq(0)
    expect(john.proposals.count).to eq(1)
    expect(Proposal.first.professional_id).to eq(john.id)
  end
  
  it 'can not create proposal with status different from pending'
  it 'can not create proposal with status different from pending'
end
