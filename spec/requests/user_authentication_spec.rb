require 'rails_helper'

describe 'User authentication' do
  it 'can not create projects without sign in' do
    get '/projects/new'

    expect(response).to redirect_to('/users/sign_in')
  end

  it 'should not view all projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    login_as jane, scope: :user
    
    get '/projects'
    follow_redirect!
    
    expect(response).to redirect_to('/')
  end

  it 'should not search projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    login_as jane, scope: :user
    
    get '/projects/search'
    follow_redirect!
    
    expect(response).to redirect_to('/')
  end

  it 'can not view edit page of another user\'s project' do
    john = User.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
      desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
      remote: true, creator: john)
    pj2 = Project.create!(title: 'Projeto 2', description: 'lorem ipsum dolor sit amet', 
      desired_abilities: 'UX', value_per_hour: 44.44, due_date: '01/10/2021', 
      remote: true, creator: jane)
    login_as jane, scope: :user

    get '/projects/1/edit', :params => {
      :project => {
        :title => "Jane's project 1", 
        :description => "Laboriosam non ab aut", 
        :desired_abilities => "UX, design", 
        :value_per_hour => 12.35, 
        :due_date => "2021-10-23", 
        :remote => true
      } 
    }

    expect(flash[:alert]).to eq('O projeto não foi encontrado')
    expect(response).to redirect_to('/')
  end

  it 'can not update another user\'s project' do
    john = User.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
      desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
      remote: true, creator: john)
    pj2 = Project.create!(title: 'Projeto 2', description: 'lorem ipsum dolor sit amet', 
      desired_abilities: 'UX', value_per_hour: 44.44, due_date: '01/10/2021', 
      remote: true, creator: jane)
    login_as jane, scope: :user

    put '/projects/1', :params => {
      :project => {
        :title => "Jane's project 1", 
        :description => "Laboriosam non ab aut", 
        :desired_abilities => "UX, design", 
        :value_per_hour => 12.35, 
        :due_date => "2021-10-23", 
        :remote => true
      } 
    }

    expect(flash[:alert]).to eq('O projeto não foi encontrado')
    expect(response).to redirect_to('/')
  end
end
