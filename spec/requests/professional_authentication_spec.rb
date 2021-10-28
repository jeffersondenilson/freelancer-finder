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
        professional_id: 1
      }
    }

    expect(response).to redirect_to('/professionals/sign_in')
    expect(Proposal.count).to eq(0)
  end
end
