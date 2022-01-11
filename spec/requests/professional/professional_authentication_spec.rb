require 'rails_helper'

describe 'Professional authentication' do
  it 'must complete profile to view projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:professional)
    login_as professional, scope: :professional

    get '/projects/1'

    expect(response).to redirect_to('/professionals/edit.1')
  end

  it 'must be signed in to create proposal' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:professional)

    post '/projects/1/proposals', params: {
      proposal: {
        message: 'John\'s proposal on project 1',
        value_per_hour: 80.80,
        hours_per_week: 20,
        finish_date: 3.days.from_now,
        professional: professional
      }
    }

    expect(response).to redirect_to('/professionals/sign_in')
    expect(Proposal.count).to eq(0)
  end

  it 'can not view edit page of another professional\'s proposal' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:completed_profile_professional)
    another_professional = create(:completed_profile_professional)
    Proposal.create!(
      {
        message: 'Schneider\'s proposal on project 1',
        value_per_hour: 99.99,
        hours_per_week: 30,
        finish_date: 1.week.from_now,
        project: pj1,
        professional: another_professional
      }
    )
    login_as professional, scope: :professional

    get '/proposals/1/edit'

    expect(response).to have_http_status(:not_found)
  end

  it 'can not update another professional\'s proposal' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1 = Project.create!(
      title: 'Projeto 1', description: 'lorem ipsum...',
      desired_abilities: 'design', value_per_hour: 12.34,
      due_date: '09/10/2021', remote: true, creator: jane
    )
    professional = create(:completed_profile_professional)
    another_professional = create(:completed_profile_professional)
    Proposal.create!(
      {
        message: 'Schneider\'s proposal on project 1',
        value_per_hour: 99.99,
        hours_per_week: 30,
        finish_date: 1.week.from_now,
        project: pj1,
        professional: another_professional
      }
    )
    login_as professional, scope: :professional

    put '/proposals/1', params: {
      proposal: {
        message: 'NOT Schneider\'s proposal on project 1',
        value_per_hour: 99.99,
        hours_per_week: 30,
        finish_date: 1.week.from_now,
        project: pj1,
        professional: another_professional
      }
    }

    expect(response).to have_http_status(:not_found)
  end
end
